local set = require '/lib/set'

local qsList = {first = 0, last = -1}

function qsList:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function qsList:pushleft (value)
  local first = self.first - 1
  self.first = first
  self[first] = value
end

function qsList:pushright (value)
  local last = self.last + 1
  self.last = last
  self[last] = value
end

function qsList:popleft ()
  local first = self.first
  if first > self.last then error("list is empty") end
  local value = self[first]
  self[first] = nil        -- to allow garbage collection
  self.first = first + 1
  return value
end

function qsList:popright ()
  local last = self.last
  if self.first > last then error("list is empty") end
  local value = self[last]
  self[last] = nil         -- to allow garbage collection
  self.last = last - 1
  return value
end

function qsList:isEmpty()
  return self.first > self.last
end

function qsList:length()
  return self.last - self.first + 1
end

function qsList:sort()
  local function partition(arr, low, high)
    local pivot = arr[high]
    local i = low - 1
    for j = low, high - 1 do
      if arr[j] <= pivot then
        i = i + 1
        arr[i], arr[j] = arr[j], arr[i]
      end
    end
    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    return i + 1
  end

  local function quicksort(arr, low, high)
    if low < high then
      local pi = partition(arr, low, high)
      quicksort(arr, low, pi - 1)
      quicksort(arr, pi + 1, high)
    end
  end

  local arr = {}
  for i = self.first, self.last do
    table.insert(arr, self[i])
  end

  quicksort(arr, 1, #arr)

  for i = self.first, self.last do
    self[i] = table.remove(arr, 1)
  end
end

function qsList:concat(otherList)
  for i = otherList.first, otherList.last do
    self:pushright(otherList[i])
  end
end

function qsList:to_set()
  local s = set:new()
  for i = self.first, self.last do
    s:insert(self[i])
  end
  return s
end

return qsList