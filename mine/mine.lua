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

local function clearSide(side)
  local passable, description = robot.detect(side)
  while not passable do
    robot.swing(side)
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

