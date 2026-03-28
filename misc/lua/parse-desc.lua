#!/usr/bin/env lua
-- --- T2-COPYRIGHT-BEGIN ---
-- t2/misc/lua/parse-desc.lua
-- Copyright (C) 2005 - 2026 The T2 SDE Project
-- SPDX-License-Identifier: GPL-2.0
-- --- T2-COPYRIGHT-END ---

-- try this:
-- 
-- this file looks quite complicated already, but a comparsion to grep might help:
--
-- time lua misc/lua/parse-desc.lua package/base/*/*.desc > /dev/null
-- time grep "^[[]" package/base/*/*.desc > /dev/null
--

require "misc/lua/sde/desc"

if #arg < 1 then
   print("Usage: lua misc/lua/parse-desc.lua [path-to-desc-file]")
   os.exit(1)
end

function printf(...)
   io.write(string.format(unpack(arg)))
end


-- parse all files
pkgs = {}
for i,file in ipairs(arg) do
   if i > 0 then
      _,_,repo,pkg = string.find(file, "package/([^/]*)/([^/]*)/*");

      -- put all parsed files into a table
      pkgs[pkg] = desc.parse(file)
   end
end

-- output
for pkg,tab in pairs(pkgs) do
   printf("Package %s:\n", pkg);

   for k,v in pairs(tab) do
      if type(v) == "table" then
	 printf("  %s: %s\n", k, table.concat(v,"\n    "));
      else
	 printf("  %s: %s\n", k, v);
      end
   end
end
