-- --- T2-COPYRIGHT-BEGIN ---
-- t2/misc/luabash/example/internal.lua
-- Copyright (C) 2006 - 2026 The T2 SDE Project
-- SPDX-License-Identifier: GPL-2.0
-- --- T2-COPYRIGHT-END ---

function plus(a,b)
   total=bash.getVariable("total")
   if total == nil then total=0 end
   prod=a*b
   total=total+prod
   print(a.." * "..b.." = "..prod)
   bash.setVariable("total", total)
   return result
end

function callbash()
   goodresult=bash.call("some_bashy_function", "trash", "test", "a", "is", "this")
   badresult=bash.call("this-command-is-intentionally-wrong")
   print ("returncodes were: "..goodresult .. " " .. badresult)
end

function redirections()
   repeat
      a=io.read()
      if a~=nil then print("xx"..a.."xx") end
   until a==nil
end

function printenv()
   env=bash.getEnvironment()
   for key,val in pairs(env) do
      print(key.."="..val)
   end
end

function zero()
   return 0
end

function one()
   return 1
end

function str()
   return "abc"
end

function two()
   return 1, "two" -- :-)
end

function boolean()
   return true
end

-- register shortcuts to functions above
bash.register("plus")
bash.register("callbash")
bash.register("redirections")
bash.register("printenv")
bash.register("zero")
bash.register("one")
bash.register("str")
bash.register("two")
bash.register("boolean")
