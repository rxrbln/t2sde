-- --- T2-COPYRIGHT-BEGIN ---
-- --- T2-COPYRIGHT-END ---

-- TODO:
--   - add "update-priority" (like "urgent,security,normal" etc)
--     (also needs to go into create_package_db and other places)

-- DESCRIPTION:
--   p = pkgdb.parse(line-iterator)
--     Parse the package.db (takes a line iterator as input)

require "sde/desc"

-- parse all packages.db information into tables
-- filelist saving commented out (eats another 30M)

local function block_lines()
	local line = lines()

	if (line == nil) or (line=="\023") then
		return nil
	end

	return line
end

local function read_deps()
	local deps={}

	for line in block_lines do
		_,_,dependency = string.find(line, "[^ ]* (.*)")
		table.insert (deps, dependency)
	end

	return deps
end

local function read_flist()
	local files={}
	local cksums={}
	local sizes={}
	local usage=0

	for line in block_lines do
		_,_,cksum,size,file = string.find(line, "^([0-9]+) ([0-9]+) (.*)")
		-- uncomment these lines if you want to save complete file list
		--      table.insert (files, file);
		--      table.insert (cksums, 1 * cksum);
		--      table.insert (sizes, 1 * size);
		usage = usage + size
	end

	return usage,files,cksums,sizes
end

local function parse(lines)
	packages = {}

	repeat                  -- parse packages
		pkgname = lines()

		if pkgname then
			print(pkgname)
			local pkg_data = {}

			if lines() ~= "\023" then -- separator line
				print ("terminating line missing\n")
			end

			pkg_data.desc  = desc.parse (block_lines)
			pkg_data.deps  = read_deps ()
			pkg_data.usage = read_flist ()

			if lines() ~= "\004" then -- separator line
				print ("terminating line missing\n")
			end

			packages[pkgname] = pkg_data
		end
	until pkgname == nil

	return packages
end
