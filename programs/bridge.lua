local state = require '/lib/state'
local set = require '/lib/set'
local qsList = require '/lib/qsList'
local inventory = require '/lib/inventory'

local bridge = {}

function bridge.check_place_block(s, ydir)
  local block_slot = inventory.get_slot(s.blacklist)
  if block_slot == nil then
    error('No empty slots found in inventory')
  end

  turtle.select(block_slot)
  if ydir == 0 then
    if turtle.detect() then
      return
    end

    s:dig_to({dir = s.dir, ydir = 0})
    if not s:place_at({dir = s.dir, ydir = 0}) then
      s.blacklist:insert(block_slot)
      return bridge.check_place_block(s, ydir)
    end

    -- it might be a block that is affected by gravity, so check again if the block is there
    if not turtle.detect() then
      s.blacklist:insert(block_slot)
      return bridge.check_place_block(s, ydir)
    end

    return
  end

  if ydir > 0 then
    if turtle.detectUp() then
      return
    end
  else
    if turtle.detectDown() then
      return
    end
  end
  
  s:dig_to({dir = s.dir, ydir = ydir})
  if not s:place_at({dir = s.dir, ydir = ydir}) then
    s.blacklist:insert(block_slot)
    return bridge.check_place_block(s, ydir)
  end

  -- it might be a block that is affected by gravity, so check again if the block is there
  if ydir > 0 then
    if not turtle.detectUp() then
      s.blacklist:insert(block_slot)
      return bridge.check_place_block(s, ydir)
    end
    return
  end

  if not turtle.detectDown() then
    s.blacklist:insert(block_slot)
    return bridge.check_place_block(s, ydir)
  end
end

function bridge.check_place_lru(s)
  s:turn_to({dir = 1})
  bridge.check_place_block(s, 0)
  s:turn_to({dir = 3})
  bridge.check_place_block(s, 0)
  bridge.check_place_block(s, 1)
end

function bridge.check_place_lrb(s)
  s:turn_to({dir = 1})
  bridge.check_place_block(s, 0)
  s:turn_to({dir = 3})
  bridge.check_place_block(s, 0)
  bridge.check_place_block(s, -1)
end

function bridge.place_torch(s, step, interval)
  if s.cur_torch_slot == nil then
    return
  end

  if step % interval ~= 0 then
    return
  end

  if inventory.is_empty(s.cur_torch_slot) then
    if s.torch_slots:length() == 0 then
      error('No torches found in inventory')
    end

    s.cur_torch_slot = s.torch_slots:popleft()
  end
  
  turtle.select(s.cur_torch_slot)
  s:place_at({dir = 0, ydir = 1})
end

function bridge.loop(s, l)
  for i=1,l do
    bridge.check_place_lrb(s)
    s:dig_to({dir = 0, ydir = 1})
    s:move_to({dir = 0, ydir = 1})
    s:dig_to({dir = 0, ydir = 1})
    s:move_to({dir = 0, ydir = 1})
    bridge.check_place_lru(s)
    s:move_to({dir = 0, ydir = -1})
    bridge.place_torch(s, i - 1, 9)
    s:move_to({dir = 0, ydir = -1})
    s:dig_to({dir = 0, ydir = 0})
    s:move_to({dir = 0, ydir = 0})
  end
end

function bridge.begin(length)
  -- initialize the state object
  local s = state:new()
  local blacklist = qsList:new()
  local torch_slots = inventory.find_all('torch')
  if torch_slots:length() > 0 then
    s.torch_slots = torch_slots

    blacklist:concat(s.torch_slots)
    blacklist:sort()
    blacklist = blacklist:to_set()
    
    s.cur_torch_slot = s.torch_slots:popleft()
  else
    blacklist = set:new()
  end
  
  s.blacklist = blacklist

  bridge.loop(s, length)
end

local args = {...}
local length = tonumber(args[1])

if length == nil then
  print("Usage: bridge <length>")
  return
end

if length <= 0 then
  print("Length must be greater than 0")
  return
end

bridge.begin(length)