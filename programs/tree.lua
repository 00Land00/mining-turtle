local state = require '/lib/state'

local tree = {}

function tree.is_wood(name)
  return string.find(name, 'log') ~= nil
end

function tree.chop(s)
  local _, data = turtle.inspect()
  if tree.is_wood(data.name) then
    s:dig_to({dir = 0, ydir = 0})
    s:move_to({dir = 0, ydir = 0})

    local height = 1
    local _, data = turtle.inspectUp()
    while tree.is_wood(data.name) do
      s:dig_to({dir = 0, ydir = 1})
      s:move_to({dir = 0, ydir = 1})

      _, data = turtle.inspectUp()
      height = height + 1
    end

    for i=1,height do
      s:move_to({dir = 0, ydir = -1})
    end
  end
end

function tree.begin()
  local s = state:new()

  tree.chop(s)
end

tree.begin()

-- return tree