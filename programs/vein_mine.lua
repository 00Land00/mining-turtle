local state = require '/lib/state'
local set = require '/lib/set'
local qsList = require '/lib/qsList'

local vein_mine = {}

-- Convert a position to a string.
--  @param pos The position to convert.
--  @return The string representation of the position.
function vein_mine.coord_to_str(pos)
  return pos[1].." "..pos[2].." "..pos[3]
end

-- Convert a string to a position.
--  @param str The string to convert.
--  @return The position representation of the string.
function vein_mine.str_to_coord(str)
  local t = {}
  for i in string.gmatch(str, "%S+") do
    table.insert(t, i)
  end
  return t
end

-- Check if the position has been visited.
--  @param s The state object, which contains the visited set.
--  @param pos The position to check.
--  @return True if the position has been visited, false otherwise.
function vein_mine.has_visited(s, pos)
  return s.visited:contains(vein_mine.coord_to_str(pos)) 
end

-- Create a whitelist of ores to mine.
--  @param s The state object, which contains the current position, direction, and other data structures.
--  @return s The state object, which now contains the whitelist of ores to mine.
function vein_mine.create_whitelist(s)
  local whitelist = set:new()

  whitelist_file = fs.open("/config/vm_whitelist", "r")
  while true do
    local line = whitelist_file.readLine()
    if line == nil then
      break
    end
    whitelist:insert(line)
  end
  whitelist_file.close()

  s.whitelist = whitelist
end

-- Check if the block is in the whitelist.
--  @param data The data of the block to check.
--  @return True if the block is in the whitelist, false otherwise.
function vein_mine.in_whitelist(s, data) 
  if data == nil then
    return false
  end
  return s.whitelist:contains(data.name)
end

-- Scans all directions (up, down, and all four sides) from the current position.
--  @param s The state object, which contains the current position, direction, and the fringe (a stack of nodes).
--  @param d The current depth of the search.
--  @return The number of new positions added to the fringe.
function vein_mine.scan_all(s)
  -- scan all four directions
  local d = s.dir
  local check_list = {
    vein_mine.has_visited(s, s:facing_pos(d)), 
    vein_mine.has_visited(s, s:facing_pos((d + 1) % 4)), 
    vein_mine.has_visited(s, s:facing_pos((d + 2) % 4)), 
    vein_mine.has_visited(s, s:facing_pos((d + 3) % 4))
  }
  
  for i=0,3 do
    if not check_list[i + 1] then
      s:turn_to({dir = (d + i) % 4})
      local _, data = turtle.inspect()
      if vein_mine.in_whitelist(s, data) then
        s.fringe:pushleft({pos = s:facing_pos(s.dir), dir = s.dir, ydir = 0})
        vein_mine.dfs(s)
      end
    end
  end

  -- scan up and down
  local _, data = turtle.inspectUp()
  if vein_mine.in_whitelist(s, data) then
    s.fringe:pushleft({pos = s:up(), dir = s.dir, ydir = 1})
    vein_mine.dfs(s)
  end
  local _, data = turtle.inspectDown()
  if vein_mine.in_whitelist(s, data) then
    s.fringe:pushleft({pos = s:down(), dir = s.dir, ydir = -1})
    vein_mine.dfs(s)
  end
end

-- Travel back to the beginning of the path.
--  @param s The state object, which contains the current position, direction, and the path (a stack of directions).
function vein_mine.go_back(s)
  -- extract the direction from the path and invert the direction
  local path_node = s.path:popleft()

  local inv_dir = s:invert_dir(path_node.dir)
  local inv_ydir = s:invert_ydir(path_node.ydir)

  -- move to the inverted direction
  s:move_to({dir = inv_dir, ydir = inv_ydir})
end

-- Depth-first search algorithm for mining veins of ores.
--  @param s The state object, which contains the current position, direction,
--           the fringe (a stack of nodes), and the path (a stack of directions).
--  @param d The current depth of the search.
function vein_mine.dfs(s)
  -- while there are still nodes in the fringe
  while not s.fringe:isEmpty() do
    local node = s.fringe:popleft()

    -- if we haven't visited this node yet
    if not vein_mine.has_visited(s, node.pos) then
      -- mark the node as visited
      

      -- go to that node
      s:dig_to(node)
      s:move_to(node)

      -- add it to the path
      s.path:pushleft{dir = s.dir, ydir = node.ydir}

      -- and continue the search
      vein_mine.scan_all(s)
    end
  end

  -- if we've reached the end of the entire vein, go back to the beginning
  vein_mine.go_back(s)
end

function vein_mine.init()
  -- initialize the state, path, visited set, and fringe
  local s = state:new()
  local path = qsList:new()
  local visited = set:new()
  local fringe = qsList:new()
  s.path = path
  s.visited = visited
  s.visited:insert(vein_mine.coord_to_str(s.pos))
  s.fringe = fringe

  -- create a whitelist of ores to mine
  vein_mine.create_whitelist(s)

  return s
end

-- Begin the vein mining process.
function vein_mine.begin()
  -- initialize the state, path, visited set, whitelist, and fringe
  local s = vein_mine.init()

  -- scan all directions from the current position
  vein_mine.scan_all(s)
end

-- vein_mine.begin()

return vein_mine