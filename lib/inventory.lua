local set = require '/lib/set'
local qsList = require '/lib/qsList'

local inventory = {}

function inventory.is_empty(slot)
  return turtle.getItemCount(slot) == 0
end

-- this is more a string function but
function inventory.contains(str, keyword)
  return string.find(str, keyword) ~= nil
end

-- search in inventory
function inventory.find(name)
  prev_slot = turtle.getSelectedSlot()
  for i=1,16 do
    turtle.select(i)
    if turtle.getItemCount(i) > 0 then
      local data = turtle.getItemDetail(i)
      if inventory.contains(data.name, name) then
        return i
      end
    end
  end
  turtle.select(prev_slot)
  return nil
end

-- search for all items in inventory that contains name
function inventory.find_all(name)
  local slots = qsList:new()
  for i=1,16 do
    turtle.select(i)
    if turtle.getItemCount(i) > 0 then
      local data = turtle.getItemDetail(i)
      if inventory.contains(data.name, name) then
        slots:pushleft(i)
      end
    end
  end
  return slots
end

-- get first non-empty slot not in blacklist
function inventory.get_slot(blacklist)
  prev_slot = turtle.getSelectedSlot()
  for i=1,16 do
    if not blacklist:contains(i) then
      turtle.select(i)
      if turtle.getItemCount(i) > 0 then
        return i
      end
    end
  end
  turtle.select(prev_slot)
  return nil
end

function inventory.has_room()
  for i=1,16 do
    if turtle.getItemCount(i) == 0 then
      return true
    end
  end
  return false
end

return inventory

-- chest api
-- function inventory.withdraw_all()
  
-- end

-- inventory config file format
-- 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
-- im defining the standard inventory layout
-- 1-4: torches, wireless modem, shulkerbox, shulker box
-- rest are blocks

-- 1. create inventory management api
  -- find item in inventory
  -- suck and drop to and from chest api
    -- get everything in chest
    -- empty everything into chest
    -- get and deposit something given a particular slot
    -- inventory config file to specify what to keep and what to remove
    -- when inventory is full. and also outline which slotsare reserved for special items
  -- shulker api
    -- place shulker at a certain direction or ydir
    -- call the previous apis
    -- put shulker back in inventory
  -- tool switching api
    -- given slot or from inventory config, equip either left or right