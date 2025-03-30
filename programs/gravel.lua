turtle.select(1)
turtle.place()
local curSlot = 1
local success, data
repeat
    turtle.dig()
    turtle.place()
    success, data = turtle.inspect()
    if not success then
        turtle.select(curSlot + 1)
        curSlot = curSlot + 1
        turtle.place()
        success, data = turtle.inspect()
    end
until not success
