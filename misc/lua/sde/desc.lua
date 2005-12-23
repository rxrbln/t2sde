-- Copyright (C) 2005 Juergen "George" Sawinski
-- Licensed under the GPL, see end of file

-- TODO:
--   -in desc.parse, check if required fields were set

-- DESCRIPTION:
--   t = desc.parse(line-iterator)
--     Parse ".desc" file format by passing a line iterator and
--     return a table, where lower-case of last entry in
--       PKG-DESC-FORMAT
--     is the key. Example:
--     Parsing "[I] Title" returns `{ title = "Title" }'

-- package object structure
desc = desc or {}
desc.__format__ = {}

-- parse .desc text ; expects line iterator function as argument
function desc.parse(desc)
	local retval = {}

	for line in desc do
		local tag,cnt

		_,_,tag,cnt = string.find(line, "([[][^]]*[]])[ ]+(.*)")
		if tag then
			local fmt = desc.__format__[tag]
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
			desc.__format__[t] = { name = tag; required = required }
		end
	end
end

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
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
