local component = require("component")
local computer = require("computer")
local robot = require("robot")
local shell = require("shell")
local sides = require("sides")

print("Mine!")

local args, options = shell.parse(...)
print(args)
print(options)

local distance = tonumber(args[1])
if not distance then
  io.stderr:write("invalid distance")
  return
end

print("tunneling distance")
print("Current energy: " .. computer.energy())

local d, f = 0, 0

local function sideToNum(side)
  if side == sides.front then
    return 0
  elseif side == sides.right then
    return 1
  elseif side == sides.back then
    return 2
  elseif side == sides.left then
    return 3
  end
end

local function face(side)
  local target = sideToNum(side)
  while f ~= target do
    if (f + 3) % 4 == target then
      robot.turnLeft()
      f = (f + 3) % 4
    else
      robot.turnRight()
      f = (f + 1) % 4
    end
  end
end

local function clearSideRaw(side, f, d)
  local impass, desc = d()
  local tries = 10
  while impass and tries > 0 do
    f()
    impass, desc = d()
    tries = tries - 1
  end
  return tries > 0
end

local function clearSide(side)
  if side == sides.top then
    return clearSideRaw(side, robot.swingUp, robot.detectUp)
  elseif side == sides.bottom then
    return clearSideRaw(side, robot.swingDown, robot.detectDown)
  else
    face(side)
    return clearSideRaw(side, robot.swing, robot.detect)
  end
end

local function move(side)
  if side == sides.top or side == sides.bottom then
    local success, desc = component.robot.move(side)
    if not success then
      return false
    end
  else
    face(side)
    robot.forward()
  end
end

local function hasValue(array, value)
  for i = 1,#array do
    if value == array[i] then
      return true
    end
  end
  return false
end

local function purgeItem(names)
  for slot = 1,robot.inventorySize() do
    local item = component.inventory_controller.getStackInInternalSlot(slot)
    if item then
      if hasValue(names, item.name) then
	robot.select(slot)
	robot.drop(item.size)
      end
    else
      return -- empty slot
    end
  end
end

local function inventoryFull()
  for i = robot.inventorySize(),1,-1 do
    local item = component.inventory_controller.getStackInInternalSlot(slot)
    if not item then
      return false
    end
  end
  return true
end

local function tunnelForward()
  if d >= distance then
    return false
  end
  d = d + 1
  clearSide(sides.left)
  if not move(sides.top) then
    return false
  end
  clearSide(sides.left)
  clearSide(sides.right)
  move(sides.bottom)
  clearSide(sides.right)
  if not move(sides.front) then
    return false
  end
  if inventoryFull() then
    return false
  end
  purgeItem({"minecraft:cobblestone", "minecraft.dirt"})
  return true
end

local function comeBack()
  while d > 0 do
    move(sides.back)
    d = d - 1
  end
end

local function chestInventory()
  face(sides.back)
  for i = 1,robot.inventorySize() do
    robot.select(i)
    robot.drop()
  end
end

repeat until not tunnelForward()
face(sides.front)
comeBack(distance)
chestInventory()
