local Rotation = require '/lib/rotation'

local position = {
  coordinate_map = {
    [0] = { x = 1, y = 0, z = 0 },
    [1] = { x = 0, y = 0, z = 1 },
    [2] = { x = -1, y = 0, z = 0 },
    [3] = { x = 0, y = 0, z = -1 },
    [4] = { x = 0, y = 1, z = 0 },
    [5] = { x = 0, y = -1, z = 0 },
  },
}

local position_mt = {
  __index = position,
  __mul = function(self, scalar)
    if type(scalar) ~= "number" then
      error("Multiplication only supports scalar values (numbers)")
    end
    return position:new(self.x * scalar, self.y * scalar, self.z * scalar)
  end,
  __add = function(self, position)
    return position:new(self.x + position.x, self.y + position.y, self.z + position.z)
  end,
  __sub = function(self, position)
    return position:new(self.x - position.x, self.y - position.y, self.z - position.z)
  end,
  __tostring = function(self)
    return "( "..tostring(self.x).." "..tostring(self.y).." "..tostring(self.z).." )"
  end,
}

function position:new(x, y, z)
  local obj = { x = x or 0, y = y or 0, z = z or 0 }
  setmetatable(obj, position_mt)
  return obj
end

function position:set(newPos)
  self.x, self.y, self.z = newPos.x, newPos.y, newPos.z
end

function position:facing(new_dir)
  if type(new_dir) ~= "number" then
    error("Expected a number")
  end

  if new_dir > 5 or new_dir < 0 then
    error("Expected a number between 0 and 5 (inclusive)")
  end

  local coord = self.coordinate_map[new_dir]
  return position:new(coord.x, coord.y, coord.z)
end

function position:dir(target_pos)
  if self.y == target_pos.y and self.z == target_pos.z then
    if self.x < target_pos.x then return Rotation.NORTH end
    if self.x > target_pos.x then return Rotation.SOUTH end
  end

  if self.x == target_pos.x and self.z == target_pos.z then
    if self.y < target_pos.y then return Rotation.UP end
    if self.y > target_pos.y then return Rotation.DOWN end
  end

  if self.x == target_pos.x and self.y == target_pos.y then
    if self.z < target_pos.z then return Rotation.EAST end
    if self.z > target_pos.z then return Rotation.WEST end
  end

  error("Target position is not fixed to two axes along the current position")
end

return position