-- parse all packages.db information into tables
-- filelist saving commented out (eats another 30M)

require "lzlib"
require "t2_desc"

function block_lines()
   local line = lines();
   if (line == nil) or (line=="\023") then
      return nil;
   end
   return line;
end

function read_deps()
   local deps={}
   for line in block_lines do
      _,_,dependency = string.find(line, "[^ ]* (.*)");
      table.insert (deps, dependency);
   end
   return deps;
end

function read_flist()
   local files={};
   local cksums={};
   local sizes={};
   local usage=0;
   for line in block_lines do
      _,_,cksum,size,file = string.find(line, "^([0-9]+) ([0-9]+) (.*)");
--    uncomment theese lines if you want to save complete file list
--      table.insert (files, file);
--      table.insert (cksums, 1 * cksum);
--      table.insert (sizes, 1 * size);
      usage = usage + size;
   end
   return usage,files,cksums,sizes;
end


zf,error = lzlib.open("./packages.db", "r");
if not zf then             -- failed to open file, print error
   print(error);
else
   lines = zf:lines();     -- obtain line iterator

   packages = {};

   repeat                  -- parse packages
      pkgname = lines();
      if pkgname then
	 print(pkgname);
	 local pkg_data = {};

	 if lines() ~= "\023" then -- separator line
	    print ("terminating line missing\n");
	 end

	 pkg_data.desc=t2_desc.parse (block_lines);
	 pkg_data.deps=read_deps ();
	 pkg_data.usage = read_flist ();
	 if lines() ~= "\004" then -- separator line
	    print ("terminating line missing\n");
	 end
	 
	 packages[pkgname] = pkg_data;
      end
   until pkgname == nil;

   _,normal_eof,error = zf:eof ();
   if not normal_eof then  -- check if stream ended because of error
      print ("-- abnormal end of stream: ", error);
   end

   ok,error = zf:close();
   if not ok then
      print ("could not close stream: ", error);
   end
   x = gcinfo ();
   print(x, "kb dynamic memory used.");
end
