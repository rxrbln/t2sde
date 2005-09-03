#!/usr/bin/env lua

-- try this:
-- 
-- this file looks quite complicated already, but a comparsion to grep might help:
--
-- time lua misc/lua/parse-desc.lua package/base/*/*.desc > /dev/null
-- time time grep "^[[]" package/base/*/*.desc > /dev/null
--

if #arg < 1 then
   print("Usage: lua misc/lua/parse-desc.lua [path-to-desc-file]")
   os.exit(1)
end

function printf(...)
   io.write(string.format(unpack(arg)))
end

-- parse PKG-DESC-FORMAT
pkg_desc_format = {}
for line in io.open("misc/share/PKG-DESC-FORMAT"):lines() do
   local required=false
   local tag

   if string.match(line, "^[[]") ~= nil then
      -- check if tag is required
      if string.match(line, "([*])") ~= nil then required=true; end

      -- use last tag definition as name
      for t in string.gfind(line,"[[]([^]]*)[]]") do tag = t; end
      tag = string.lower(tag)

      -- sort into pkg_desc_format
      for t in string.gfind(line,"([[][^]]*[]])") do 
	 pkg_desc_format[t] = { name = tag; required = required }
      end
   end
end

-- parse .desc file
function parse_desc(fname)
   local retval = {}

   printf("Parsing %s...\n", fname)

   local desc = io.open(fname):lines();

   for line in desc do
      local tag,cnt

      _,_,tag,cnt = string.find(line, "([[][^]]*[]])[ ]+(.*)")
      if tag then
	 for t, d in pairs(pkg_desc_format) do
	    if t == tag then
	       retval[d.name] = retval[d.name] or {}
	       table.insert(retval[d.name], cnt)
	    end
	 end
      end
   end

   return retval
end

-- parse all files
pkgs = {}
for i,file in pairs(arg) do
   if i > 0 then
      _,_,repo,pkg = string.find(file, "package/([^/]*)/([^/]*)/*");

      -- put all parsed files into a table
      pkgs[pkg] = parse_desc(file)
   end
end

-- output
for pkg,tab in pairs(pkgs) do
   printf("Package %s:\n", pkg);

   for k,v in pairs(tab) do
      if type(v) == "table" then
	 printf("  %s %s\n", k, table.concat(v,"\n    "));
      else
	 printf("  %s %s\n", k, v);
      end
   end
end
