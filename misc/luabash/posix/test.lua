-- test posix library

require ("posix")

ox=posix

-- code for the new md5sums file ...

local stat = ox.stat("/dev/fd")
if stat.type == "link" then
  print ("/dev/fd is a symlink.")
  print ("^--> "..ox.readlink("/dev/fd"))
end

stat = ox.stat("test.lua")
print ("test.lua size: "..stat.size)

print""
print(ox.version)
