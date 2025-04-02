local rotation = {
  NORTH = 0,
  EAST = 1,
  SOUTH = 2,
  WEST = 3,
  UP = 4,
  DOWN = 5,

  direction_map = {
    [0] = "north",
    [1] = "east",
    [2] = "south",
    [3] = "west",
    [4] = "up",
    [5] = "down",
  }
}

local rotation_mt = {
  __index = rotation,
  __tostring = function(self)
    return "( "..string.upper(self.direction_map[self.dir]).." )"
  end,
}

function rotation:new(dir)
  local obj = { dir = dir or 0 }
  setmetatable(obj, rotation_mt)
  return obj
end

function rotation:inv_dir(dir) return (dir + 2) % 4 end
function rotation:inv_ydir(ydir) return ydir * -1 end

function rotation:apply_dir(i)
  if type(i) ~= "number" then 
    error("Expected a number")
  end

  self.dir = (self.dir + i) % 4
end

function rotation:set_dir(new_dir)
  if type(new_dir) ~= "number" then
    error("Expected a number")
  end

  if new_dir > 3 or new_dir < 0 then
    error("Expected a number between 0 and 3 (inclusive)")
  end

  self.dir = new_dir
end

return rotation