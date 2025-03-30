local state = require '/lib/state'
local set = require '/lib/set'
local qsList = require '/lib/qsList'
local inventory = require '/lib/inventory'

local s_staircase = {}

function s_staircase.check_place_block(s, ydir)
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
      return s_staircase.check_place_block(s, ydir)
    end

    -- it might be a block that is affected by gravity, so check again if the block is there
    if not turtle.detect() then
      s.blacklist:insert(block_slot)
      return s_staircase.check_place_block(s, ydir)
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
    return s_staircase.check_place_block(s, ydir)
  end

  -- it might be a block that is affected by gravity, so check again if the block is there
  if ydir > 0 then
    if not turtle.detectUp() then
      s.blacklist:insert(block_slot)
      return s_staircase.check_place_block(s, ydir)
    end
    return
  end

  if not turtle.detectDown() then
    s.blacklist:insert(block_slot)
    return s_staircase.check_place_block(s, ydir)
  end
end

function s_staircase.fixed_loop(s, d, ydir)
  if ydir > 0 then
    for i=1,d do
      s_staircase.check_place_block(s, -1)
      s:dig_to({dir = 0, ydir = 1})
      s:move_to({dir = 0, ydir = 1})
      s:dig_to({dir = 0, ydir = 1})
      s:dig_to({dir = 0, ydir = 0})
      s:move_to({dir = 0, ydir = 0})
    end
  else
    for i=1,d do
      s_staircase.check_place_block(s, -1)
      s:dig_to({dir = 0, ydir = 1})
      s:dig_to({dir = 0, ydir = 0})
      s:move_to({dir = 0, ydir = 0})
      s:dig_to({dir = 0, ydir = 1})
      s:dig_to({dir = 0, ydir = -1})
      s:move_to({dir = 0, ydir = -1})
    end
  end
end

function s_staircase.loop(s, ydir)
  if ydir > 0 then
    while true do
      s_staircase.check_place_block(s, -1)

      if not s:move_to({dir = 0, ydir = 1}) then
        break
      end
      if not s:move_to({dir = 0, ydir = 0}) then
        break
      end
    end
  else
    while true do
      s_staircase.check_place_block(s, -1)
      
      if not s:move_to({dir = 0, ydir = 1}) then
        break
      end
      if not s:move_to({dir = 0, ydir = 0}) then
        break
      end
    end
  end
end

function s_staircase.begin(d, dir)
  -- initialize the state object
  local s = state:new()

  s.blacklist = set:new()

  local ydir = 0
  if dir == "up" then
    ydir = 1
  elseif dir == "down" then
    ydir = -1
  else
    error('Invalid direction')
  end

  if d == "loop" then
    s_staircase.loop(s, ydir)
  else
    s_staircase.fixed_loop(s, tonumber(d), ydir)
  end
end

-- return s_staircase

local args = {...}
local d = args[1]
local dir = args[2]

s_staircase.begin(d, dir)