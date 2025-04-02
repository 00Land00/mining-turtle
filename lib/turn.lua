local turn = {}

function turn:left(state, steps)
  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1

  state.rot:apply_dir(-1 * steps)

  for i = 1,steps,1 do
    turtle.turnLeft()
  end
end

function turn:right(state, steps)
  if steps ~= nil and type(steps) ~= "number" then
    error("Expected a number")
  end

  if steps ~= nil and steps <= 0 then
    error("Expected a positive integer")
  end

  steps = steps or 1

  state.rot:apply_dir(1 * steps)

  for i = 1,steps,1 do
    turtle.turnRight()
  end
end

function turn:to(state, new_dir)
  if type(new_dir) ~= "number" then
    error("Expected a number")
  end

  if new_dir > 3 or new_dir < 0 then
    error("Expected a number between 0 and 3 (inclusive)")
  end

  if state.rot.dir == new_dir then
    return
  end

  if (state.rot.dir + 1) % 4 == new_dir then
    self:right(state, 1)
    return
  end

  if (state.rot.dir + 2) % 4 == new_dir then
    self:right(state, 2)
    return
  end

  if (state.rot.dir + 3) % 4 == new_dir then
    self:left(state, 1)
    return
  end
end

return turn