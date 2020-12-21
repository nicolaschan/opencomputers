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

local d = 0


local function clearSideRaw(side, f)
  local impass, desc = robot.detect(side)
  while impass do
    f()
    impass, desc = robot.detect(side)
  end
end

local function clearSide(side)
  if side == sides.front then
    clearSideRaw(side, robot.swing)
  elseif side == sides.top then
    clearSideRaw(side, robot.swingUp)
  elseif side == sides.bottom then
    clearSideRaw(side, robot.swingDown)
  elseif side == sides.left then
    robot.turnLeft()
    clearSideRaw(side, robot.swing)
    robot.turnRight()
  elseif side == sides.right then
    robot.turnRight()
    clearSideRaw(side, robot.swing)
    robot.turnLeft()
  elseif side == sides.back then
    robot.turnAround()
    clearSideRaw(side, robot.swing)
    robot.turnAround()
  end
end

local function move(side)
  clearSide(side)
  component.robot.move(side)
end

local function tunnelForward()
  if d >= distance then
    return false
  end
  d = d + 1
  move(sides.front)
  clearSide(sides.top)
  return true
end

repeat until not tunnelForward()

