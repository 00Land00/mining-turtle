local state = require '/lib/state'
local set = require '/lib/set'
local qsList = require '/lib/qsList'
local inventory = require '/lib/inventory'

local staircase = {}

function staircase.check_place_lru(s)
  s:turn_to({dir = 1})
  staircase.check_place_block(s, 0)
  s:turn_to({dir = 3})
  staircase.check_place_block(s, 0)
  staircase.check_place_block(s, 1)
end

function staircase.check_place_lrb(s)
  s:turn_to({dir = 1})
  staircase.check_place_block(s, 0)
  s:turn_to({dir = 3})
  staircase.check_place_block(s, 0)
  staircase.check_place_block(s, -1)
end

function staircase.check_place_lr(s)
  s:turn_to({dir = 1})
  staircase.check_place_block(s, 0)
  s:turn_to({dir = 3})
  staircase.check_place_block(s, 0)
end

function staircase.check_place_block(s, ydir)
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
      return staircase.check_place_block(s, ydir)
    end

    -- it might be a block that is affected by gravity, so check again if the block is there
    if not turtle.detect() then
      s.blacklist:insert(block_slot)
      return staircase.check_place_block(s, ydir)
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
    return staircase.check_place_block(s, ydir)
  end

  -- it might be a block that is affected by gravity, so check again if the block is there
  if ydir > 0 then
    if not turtle.detectUp() then
      s.blacklist:insert(block_slot)
      return staircase.check_place_block(s, ydir)
    end
    return
  end

  if not turtle.detectDown() then
    s.blacklist:insert(block_slot)
    return staircase.check_place_block(s, ydir)
  end
end

function staircase.place_staircase(s, ydir)
  turtle.select(s.cur_stairs_slot)
  s:place_at({dir = ((ydir - 1) % 4), ydir = -1})

  if inventory.is_empty(s.cur_stairs_slot) then
    if s.stairs_slots:length() == 0 then
      error('No stairs found in inventory')
    end

    s.cur_stairs_slot = s.stairs_slots:popleft()
  end
end

function staircase.place_torch(s, step, interval, ydir)
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
  s:place_at({dir = ((ydir - 1) % 4), ydir = 1})
end

function staircase.layer_up(s)
  staircase.check_place_lrb(s)

  s:dig_to({dir = 0, ydir = 1})
  s:move_to({dir = 0, ydir = 1})

  staircase.check_place_lr(s)
  s:dig_to({dir = 0, ydir = 1})
  s:move_to({dir = 0, ydir = 1})
  
  staircase.check_place_lr(s)
  s:dig_to({dir = 0, ydir = 1})
  s:move_to({dir = 0, ydir = 1})

  staircase.check_place_lr(s)
  s:dig_to({dir = 0, ydir = 1})
  s:move_to({dir = 0, ydir = 1})

  staircase.check_place_lru(s)
end

function staircase.layer_down(s)
  staircase.check_place_lru(s)

  s:dig_to({dir = 0, ydir = -1})
  s:move_to({dir = 0, ydir = -1})

  staircase.check_place_lr(s)
  s:dig_to({dir = 0, ydir = -1})
  s:move_to({dir = 0, ydir = -1})

  staircase.check_place_lr(s)
  s:dig_to({dir = 0, ydir = -1})
  s:move_to({dir = 0, ydir = -1})

  staircase.check_place_lr(s)
  s:dig_to({dir = 0, ydir = -1})
  s:move_to({dir = 0, ydir = -1})

  staircase.check_place_lrb(s)
end

function staircase.loop(s, d, ydir)
  if ydir > 0 then
    for i=1,d do
      staircase.layer_up(s)
      s:move_to({dir = 0, ydir = -1})
      staircase.place_torch(s, i - 1, 9, ydir)
      s:move_to({dir = 0, ydir = -1})
      s:move_to({dir = 0, ydir = -1})
      staircase.place_staircase(s, ydir)
      s:dig_to({dir = 0, ydir = 0})
      s:move_to({dir = 0, ydir = 0})
    end
  else
    s:dig_to({dir = 0, ydir = 1})
    s:move_to({dir = 0, ydir = 1})

    s:dig_to({dir = 0, ydir = 1})
    s:move_to({dir = 0, ydir = 1})

    s:dig_to({dir = 0, ydir = 1})
    s:move_to({dir = 0, ydir = 1})

    for i=1,d do
      staircase.layer_down(s)
      s:move_to({dir = 0, ydir = 1})
      staircase.place_staircase(s, ydir)
      s:move_to({dir = 0, ydir = 1})
      s:move_to({dir = 0, ydir = 1})
      staircase.place_torch(s, i - 1, 9, ydir)
      s:dig_to({dir = 0, ydir = 0})
      s:move_to({dir = 0, ydir = 0})
    end

    s:dig_to({dir = 0, ydir = -1})
    s:move_to({dir = 0, ydir = -1})

    s:dig_to({dir = 0, ydir = -1})
    s:move_to({dir = 0, ydir = -1})

    s:dig_to({dir = 0, ydir = -1})
    s:move_to({dir = 0, ydir = -1})
  end
end

function staircase.begin(depth, ydir)
  -- initialize the state object
  local s = state:new()
  
  local blacklist = qsList:new()

  local torch_slots = inventory.find_all('torch')
  if torch_slots:length() > 0 then
    s.torch_slots = torch_slots
    blacklist:concat(s.torch_slots)
  end
  
  local stairs_slots = inventory.find_all('stairs')
  if stairs_slots:length() == 0 then
    error('No stairs found in inventory')
  end
  s.stairs_slots = stairs_slots

  blacklist:concat(s.stairs_slots)
  blacklist:sort()
  blacklist = blacklist:to_set()
  s.blacklist = blacklist

  s.cur_stairs_slot = s.stairs_slots:popleft()
  if s.torch_slots ~= nil then
    s.cur_torch_slot = s.torch_slots:popleft()
  end

  if ydir == "up" then
    staircase.loop(s, depth, 1)
  end
  if ydir == "down" then
    staircase.loop(s, depth, -1)
  end
end

local args = {...}
local depth = tonumber(args[1])
local ydir = args[2]

if depth == nil then
  error('Usage: staircase <depth>')
end

if depth < 1 then
  error('Depth must be greater than 0')
end

if ydir ~= "up" and ydir ~= "down" then
  error('Y direction must be either "up" or "down"')
end

staircase.begin(depth, ydir)
