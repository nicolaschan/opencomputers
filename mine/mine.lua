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
    robot.turnRight()
    f = (f + 1) % 4
  end
end

local function clearSideRaw(side, f, d)
  local impass, desc = d()
  while impass do
    f()
    impass, desc = d()
  end
end

local function clearSide(side)
  if side == sides.top then
    clearSideRaw(side, robot.swingUp, robot.detectUp)
  elseif side == sides.bottom then
    clearSideRaw(side, robot.swingDown, robot.detectDown)
  else
    face(side)
    clearSideRaw(side, robot.swing, robot.detect)
  end
end

local function move(side)
  clearSide(side)
  if side == sides.top or side == sides.bottom then
    component.robot.move(side)
  else
    face(side)
    robot.forward()
  end
end

local function tunnelForward()
  if d >= distance then
    return false
  end
  d = d + 1
  move(sides.front)
  clearSide(sides.left)
  move(sides.top)
  clearSide(sides.left)
  clearSide(sides.right)
  move(sides.bottom)
  clearSide(sides.right)
  return true
end

repeat until not tunnelForward()

