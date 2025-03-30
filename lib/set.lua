local set = {}

function set:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function set:insert(v)
  -- we assume that v is of type STRING or INT
  self[v] = true
end

function set:remove(v)
  self[v] = nil
end

function set:contains(v)
  return self[v]
end

function set:union(other)
  local new_set = set:new()
  for k, _ in pairs(self) do
    new_set:insert(k)
  end
  for k, _ in pairs(other) do
    new_set:insert(k)
  end
  return new_set
end

return set