local Position = require '/lib/position'
local Rotation = require '/lib/rotation'

local state = {
  pos = Position:new(0, 0, 0),
  rot = Rotation:new(0)
}

function state:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return state

-- function state:forward() return {self.pos[1] + 1, self.pos[2], self.pos[3]} end
-- function state:backward() return {self.pos[1] - 1, self.pos[2], self.pos[3]} end
-- function state:left() return {self.pos[1], self.pos[2], self.pos[3] - 1} end
-- function state:right() return {self.pos[1], self.pos[2], self.pos[3] + 1} end
-- function state:up() return {self.pos[1], self.pos[2] + 1, self.pos[3]} end
-- function state:down() return {self.pos[1], self.pos[2] - 1, self.pos[3]} end

-- function state:facing_pos(dir)
--   if dir == 0 then
--     return self:forward()
--   end
--   if dir == 1 then
--     return self:right()
--   end
--   if dir == 2 then
--     return self:backward()
--   end
--   if dir == 3 then
--     return self:left()
--   end
-- end

-- function state:new_dir(i)
--   return (self.dir + i) % 4
-- end

-- function state:invert_dir(dir)
--   return (dir + 2) % 4
-- end

-- function state:invert_ydir(ydir)
--   return ydir * -1
-- end

-- function state:turn_to(node)
--   if self.dir == node.dir then
--     return
--   end
  
--   diff = self.dir - node.dir
--   if math.abs(diff) == 2 then
--     self.dir = self:new_dir(2)
--     turtle.turnRight()
--     turtle.turnRight()
--     return
--   end

--   if math.abs(diff) == 1 then
--     diff = diff * -1
--   end

--   if diff > 0 then
--     self.dir = self:new_dir(1)
--     turtle.turnRight()
--     return
--   end
--   self.dir = self:new_dir(-1)
--   turtle.turnLeft()
-- end

-- function state:place_at(node, slot)
--   self:turn_to(node)

--   slot = slot or nil
--   if slot ~= nil then
--     turtle.select(slot)
--   end

--   if node.ydir ~= 0 then
--     if node.ydir > 0 then
--       return turtle.placeUp()
--     end
--     return turtle.placeDown()
--   end

--   return turtle.place()
-- end

-- function state:dig_to(node)
--   self:turn_to(node)

--   if node.ydir ~= 0 then
--     if node.ydir > 0 then
--       turtle.digUp()
--     else
--       turtle.digDown()
--     end
--     return
--   end

--   while true do
--     if not turtle.detect() then
--       break
--     end
--     turtle.dig()
--   end
-- end

-- function state:move_to(node)
--   self:turn_to(node)

--   if node.ydir ~= 0 then
--     if node.ydir > 0 then
--       self.pos = self:up()
--       return turtle.up()
--     else
--       self.pos = self:down()
--       return turtle.down()
--     end
--   end

--   self.pos = self:facing_pos(self.dir)
--   return turtle.forward()
-- end

-- function state:move_back(node)
--   self:turn_to(node)

--   if node.ydir ~= 0 then
--     if node.ydir > 0 then
--       self.pos = self:down()
--       turtle.down()
--     else
--       self.pos = self:up()
--       turtle.up()
--     end
--     return
--   end

--   self.pos = self:facing_pos(self:invert_dir(self.dir))
--   turtle.back()
-- end

-- return state

-- TODO:

-- 2. create refuel check api
  -- check if fuel is low and present warning
  -- refuel from a slot or chest
  -- given estimate travel, check if fuel level is enough
  -- refuel from nether lava pool program
-- 3. create general mining program (DONE)
-- 4. create bridge builder program
-- 5. create staircase builder program (DONE)
-- 6. create startup program
  -- this startup program should also be possible to be run remotely from a phone
-- 7. learn how to use phones
  -- mainly for running the startup program for a particular turtle from the phone
-- 8. create pathfinding library