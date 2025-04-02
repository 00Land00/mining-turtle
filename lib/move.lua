local Rotation = require '/lib/rotation'
local Turn = require '/lib/turn'

local move = {}

function move:forward(state, steps)
  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1

  local pos_offset = state.pos:facing(state.rot.dir) * steps
  state.pos:set(state.pos + pos_offset)

  for i = 1,steps,1 do
    turtle.forward()
  end
end

function move:backward(state, steps)
  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1
  
  Turn:right(state, 2)
  
  self:forward(state, steps)
end

function move:left(state, steps)
  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1

  Turn:left(state, 1)

  self:forward(state, steps)
end

function move:right(state, steps)
  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1

  Turn:right(state, 1)

  self:forward(state, steps)
end

function move:up(state, steps)
  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1

  local pos_offset = state.pos:up() * steps
  state.pos:set(state.pos + pos_offset)

  for i = 1,steps,1 do
    turtle.up()
  end
end

function move:down(state, steps)
  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1

  local pos_offset = state.pos:down() * steps
  state.pos:set(state.pos + pos_offset)

  for i = 1,steps,1 do
    turtle.down()
  end
end

function move:facing(state, new_dir, steps)
  if type(new_dir) ~= "number" then
    error("Expected a number")
  end

  if new_dir > 5 or new_dir < 0 then
    error("Expected a number between 0 and 5 (inclusive)")
  end

  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1

  if new_dir == Rotation.UP then
    self:up(state, steps)
    return
  end

  if new_dir == Rotation.DOWN then
    self:down(state, steps)
    return
  end

  Turn:to(state, new_dir)

  self:forward(state, steps)
end

return move