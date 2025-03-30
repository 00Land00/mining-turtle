local state = require '/lib/state'
local set = require '/lib/set'
local vein_mine = require '/programs/vein_mine'
local inventory = require '/lib/inventory'

local strip_mine = {}

function strip_mine.create_inv_whitelist()
  local whitelist = set:new()

  whitelist_file = fs.open("/config/inv_whitelist", "r")
  while true do
    local line = whitelist_file.readLine()
    if line == nil then
      break
    end
    whitelist:insert(line)
  end
  whitelist_file.close()

  return whitelist
end

function strip_mine.scan_front(s)
  local _, data = turtle.inspect()
  if vein_mine.in_whitelist(s, data) then
    s.fringe:pushleft({pos = s:facing_pos(s.dir), dir = s.dir, ydir = 0})
    vein_mine.dfs(s)
  end
end

function strip_mine.scan_above_below(s, above, below)
  if above then
    local _, data = turtle.inspectUp()
    if vein_mine.in_whitelist(s, data) then
      s.fringe:pushleft({pos = s:up(), dir = s.dir, ydir = 1})
      vein_mine.dfs(s)
    end
  end

  if below then
    local _, data = turtle.inspectDown()
    if vein_mine.in_whitelist(s, data) then
      s.fringe:pushleft({pos = s:down(), dir = s.dir, ydir = -1})
      vein_mine.dfs(s)
    end
  end
end

function strip_mine.scan_sides(s, l_to_r)
  if l_to_r then
    -- scan left to right
    s:turn_to({dir = 3})
    strip_mine.scan_front(s)

    s:turn_to({dir = 0})
    strip_mine.scan_front(s)

    s:turn_to({dir = 1})
    strip_mine.scan_front(s)
  else
    -- scan right to left
    s:turn_to({dir = 1})
    strip_mine.scan_front(s)

    s:turn_to({dir = 0})
    strip_mine.scan_front(s)

    s:turn_to({dir = 3})
    strip_mine.scan_front(s)
  end
end

function strip_mine.check_layer(s, i)
  strip_mine.scan_sides(s, true)
  strip_mine.scan_above_below(s, true, true)
  
  s:dig_to({dir = s.dir, ydir = 1})
  s:dig_to({dir = s.dir, ydir = -1})

  s:move_to({dir = s.dir, ydir = 1})
  strip_mine.scan_sides(s, false)
  strip_mine.scan_above_below(s, true, false)

  s:move_to({dir = s.dir, ydir = -1})
  s:move_to({dir = s.dir, ydir = -1})
  strip_mine.scan_sides(s, true)
  strip_mine.scan_above_below(s, false, true)

  s:move_to({dir = s.dir, ydir = 1})
  s:turn_to({dir = 0})

  strip_mine.place_torch(s, 9, i - 1)
end

function strip_mine.place_torch(s, interval, step)
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
  s:place_at({dir = 0, ydir = -1})
end

function strip_mine.clear_inventory(s)
  for i=1,16 do
    turtle.select(i)
    data = turtle.getItemDetail(i)
    if data ~= nil and s.inv_whitelist:contains(data.name) then
      s.blacklist:insert(i)
    end
  end

  local slot = inventory.get_slot(s.blacklist)
  while slot ~= nil do
    turtle.select(slot)
    turtle.drop()
    slot = inventory.get_slot(s.blacklist)
  end

  s.blacklist = s.torch_slots:to_set()
  s.blacklist:insert(s.cur_torch_slot)
end

function strip_mine.deposit_inventory(s)
  for i=1,16 do
    turtle.select(i)
    data = turtle.getItemDetail(i)
    if data ~= nil and s.inv_whitelist:contains(data.name) and not s.blacklist:contains(i) then
      turtle.dropDown()
    end
  end
end

function strip_mine.loop(s)
  for i=1,s.length do
    strip_mine.check_layer(s, i)

    s:dig_to({dir = 0, ydir = 0})
    s:move_to({dir = 0, ydir = 0})

    if not inventory.has_room() then
      strip_mine.clear_inventory(s)
      strip_mine.go_back(s, i)
      strip_mine.deposit_inventory(s)
      strip_mine.continue_from(s, i)
    end
  end

  strip_mine.go_back(s, s.length)
  strip_mine.deposit_inventory(s)
end

function strip_mine.go_back(s, length)
  for i=1,length do
    s:dig_to({dir = 2, ydir = 0})
    s:move_to({dir = 2, ydir = 0})
  end
end

function strip_mine.continue_from(s, length)
  for i=1,length do
    s:move_to({dir = 0, ydir = 0})
  end
end

function strip_mine.begin(length)
  -- initialize the state object
  local s = vein_mine.init()
  s.length = length

  -- find the torch slot
  local torch_slots = inventory.find_all('torch')
  if torch_slots:length() == 0 then
    error('No torches found in inventory')
  end
  s.torch_slots = torch_slots

  s.inv_whitelist = strip_mine.create_inv_whitelist()
  s.blacklist = set:new()
  s.blacklist = s.blacklist:union(s.torch_slots:to_set())

  s.cur_torch_slot = s.torch_slots:popleft()

  strip_mine.loop(s)
end

-- return strip_mine

strip_mine.begin(1000)