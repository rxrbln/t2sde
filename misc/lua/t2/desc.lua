-- Copyright (C) 2005 Juergen "George" Sawinski
-- Licensed under the GPL, see end of file

-- Description:
--   FIXME

-- package object
t2 = t2 or {}
t2.desc = t2.desc or {}
t2.desc.__format__ = {}

-- parse .desc text ; expects line iterator function as argument
local function parse(desc)
	local retval = {}

	for line in desc do
		local tag,cnt

		_,_,tag,cnt = string.find(line, "([[][^]]*[]])[ ]+(.*)")
		if tag then
			local fmt = t2.desc.__format__[tag]
			if fmt then
				retval[fmt.name] = retval[fmt.name] or {}
				table.insert(retval[fmt.name], cnt)
			end
		end
	end

	-- FIXME check if required fields are set

	return retval
end

-- init: parse PKG-DESC-FORMAT
for line in io.open("misc/share/PKG-DESC-FORMAT"):lines() do
	local required=false
	local tag

	if string.match(line, "^[[]") ~= nil then
		-- check if tag is required
		if string.match(line, "([*])") ~= nil then required=true; end

		-- use last tag definition as name
		for t in string.gfind(line,"[[]([^]]*)[]]") do tag = t; end
		tag = string.lower(tag)

		-- sort into __format__
		for t in string.gfind(line,"([[][^]]*[]])") do 
			t2.desc.__format__[t] = { name = tag; required = required }
		end
	end
end

-- insert methods
t2.desc.parse = parse;

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
