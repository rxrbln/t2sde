-- Copyright (C) 2005 Juergen "George" Sawinski
-- Licensed under the GPL, see end of file

-- file interface
hook = {}
local hook_meta = { __index = {} }

setmetatable(hook, hook_meta)

-- functions
function hook.new()
   local h = { data = {} }
   return setmetatable(h, hook_meta)
end

-- methods
function hook_meta.__call()
   return hook.new()
end

function hook_meta.__index:add(f)
   if type(f) == "table" then
      for _,v in pairs(f) do
	 self:add(v)
      end
   else
      if type(f) == "string" then
	 local x = loadstring(f)
	 table.insert(self.data, x)
      elseif type(f) == "function" then
	 table.insert(self.data, f)
      else
	 assert(type(f) ~= "function", "argument must be a function (or string)")
      end
   end
end

function hook_meta.__index:clear()
   self.data = {}
end

function hook_meta.__index:run()
   for k,v in pairs(self.data) do
      if v then v() end
   end
end

-- TEST:

h = hook()

function some_hook()
   print "some_hook"
end

h:add( some_hook )
h:add [[ print("another hook") ]]
h:add{
   function()
      print("hello world!")
   end
}

h:run()
h:clear()
h:run()

-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
