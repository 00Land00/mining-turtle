local state = require '/lib/state'
local set = require '/lib/set'
local qsList = require '/lib/qsList'
local inventory = require '/lib/inventory'

local refuel = {}

function refuel.layer_down(s)
  local success, data = turtle.inspectDown()
  local step = 0
  if not success then
    return
  end
  
  while string.find(data.name, "lava") ~= nil do
    s:place_at({dir = 0, ydir = -1})
    turtle.refuel()

    s:move_to({dir = 0, ydir = -1})
    _, data = turtle.inspectDown()
    step = step + 1
  end

  for i=1,step do
    s:move_to({dir = 0, ydir = 1})
  end
end

function refuel.loop(s)
  local step = 0
  while turtle.getFuelLevel() <= turtle.getFuelLimit() - 1000 do
    refuel.layer_down(s)
    if turtle.detect() then
      break
    end

    s:move_to({dir = 0, ydir = 0})
    step = step + 1
  end

  for i=1,step do
    s:move_to({dir = 2, ydir = 0})
  end
end

function refuel.begin()
  -- initialize the state object
  local s = state:new()

  local bucket_slot = inventory.find('bucket')
  if bucket_slot == nil then
    error('No bucket found in inventory')
  end
  s.bucket_slot = bucket_slot

  -- refuel
  refuel.loop(s)
end

refuel.begin()