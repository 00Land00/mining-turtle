local arg = {...}
local path = arg[1]

local transfer = {}

function transfer.create_folders(path)
  shell.run("mkdir", path.."lib")
  shell.run("mkdir", path.."programs")
  shell.run("mkdir", path.."config")
end

function transfer.remove_old_lib(path)
  shell.run("rm", path.."lib/*")
end

function transfer.copy_new_lib(path)
  shell.run("cp", "lib/*", path.."lib")
end

function transfer.remove_old_programs(path)
  shell.run("rm", path.."programs/*")
end

function transfer.copy_new_programs(path)
  shell.run("cp", "programs/*", path.."programs")
end

function transfer.remove_config(path)
  shell.run("rm", path.."config/*")
end

function transfer.copy_new_config(path)
  shell.run("cp", "config/*", path.."config")
end

function transfer.begin(path)
  if path == nil then
    print("Usage: transfer <path>")
    return
  end

  transfer.create_folders(path)

  transfer.remove_old_lib(path)
  transfer.remove_old_programs(path)
  transfer.remove_config(path)

  transfer.copy_new_lib(path)
  transfer.copy_new_programs(path)
  transfer.copy_new_config(path)
end

transfer.begin(path)