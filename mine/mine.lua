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

local function tunnelForward()
  if d > distance then
    return false
  end
  d = d + 1
  robot.swing()
  robot.forward()
  return true
end

repeat until not tunnelForward()

