-- Copyright (C) 2005 Juergen "George" Sawinski
-- Licensed under the GPL, see end of file

-- TODO:
--  - add boolean option argument types
--  - maybe other types needed ?

-- DESCRIPTION:
--   opts,args,err = getopt(arg-list, option-definition)
--     Parses the "arg-list" according to "option-definition" and
--     returns the parsed options "opts", additional arguments "args" and
--     possibly an error.
--    
--     Option definition format:
--        key         Option key (e.g. key = "help")
--        option      String or list of options (e.g. option = {"-h", "--help"})
--        default     Default value (e.g. default = false)
--        argument    This option has no argument (ARG.none), a required
--                    argument (ARG.required) or an optional argument (ARG.optional)
--        flag        The option is flagged: 
--                         number (OPT.number)
--                         incremental (OPT.incremental)
--  Example: see below

ARG = { 
	none = 0, 
	required = 1,
	optional = 2 
}

OPT = {
	none = 0,
	string = 0,
	number = 1,
	--boolean = 2,	
	incremental = 10,
}

function getopt(args,def)
	local opt = {}
	local arg = {}
	local nargs = table.getn(args)

	-- first pass: defaults
	for _,d in pairs(def) do
		if d.default ~= nil then 
			opt[d.key] = d.default
		end
	end

	-- Second pass: parse arguments
	local i=1 
	repeat
		for _,d in pairs(def) do
			local found = false
			
			-- FIXME is there some shorter version for this:
			if type(d.option) == "string" then
				if d.option == args[i] then found=true end
			else
				for k=1,table.getn(d.option) do
					if d.option[k] == args[i] then
						found = true
					end
				end
			end
			
			-- process option and arguments
			if found then
				local val = true
				local nextisopt = false
				local havearg = false
				
				-- check if next is an argument (not option)
				if args[i+1] and string.sub(args[i+1],1,1) == "-" then
					nextisopt = true
				end
				
				-- option argument ?
				if nextisopt and d.argument == ARG.required then
					return nil, nil, "Missing option argument for `" .. args[i] .. "'"
				end
				
				if not nextisopt and
					(d.argument == ARG.required 
						or d.argument == ARG.optional) then
					args[i] = nil 
					i = i+1
					
					val = args[i]
					
					havearg = true
				end

				-- flags ?
				if d.flag then
					if d.flag == OPT.number then
						val = tonumber(val)
					elseif d.flag == OPT.incremental then
						val = opt[d.key] + 1
					end
				end

				-- finally assign value
				opt[d.key] = val

				-- remove key from list (see third pass)
				args[i] = nil
			end
		end
	i=i+1
	until i>nargs

	-- Third pass: check option, sort arguments
	for i=1,nargs do
		if args[i] then
			if string.sub(args[i],1,1) == "-" then
				return nil, nil, "Unrecognized option `" .. args[i] .. "'"
			else
				table.insert(arg, args[i])
			end
		end
	end

	-- done
	return opt,arg
end


-- EXAMPLE
if false then
	opt,arg,err = getopt(arg, {
		{
			key      = "help",
			option   = { "-h", "-help", "--help" },
		},
		{
			key      = "verbose",
			option   = { "-v", "-verbose", "--verbose" },
			default  = 0,
			flag     = OPT.incremental
		},
	})

	if not opt then
		print "ERR:"
		print(err)
		os.exit(-1)
	end

	print "OPTS:"
	for k,v in pairs(opt) do
		print("",k,v)
	end

	print "ARGS:"
	for k,v in pairs(arg) do
		print("",k,v)
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

