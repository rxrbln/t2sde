-- --- T2-COPYRIGHT-BEGIN ---
-- t2/misc/lua/lzlib/zlibtest.lua
-- Copyright (C) 2005 - 2026 The T2 SDE Project
-- SPDX-License-Identifier: GPL-2.0
-- --- T2-COPYRIGHT-END ---

-- output all lines of compressed file ./test.gz

require "lzlib"

zf,error = lzlib.open("./test.gz", "r");
if not zf then             -- failed to open file, print error
   print(error);
else
   lines = zf:lines();     -- obtain line iterator

   for x in lines do       -- output contents 
      print (x);
   end

   _,normal_eof,error = zf:eof ();
   if not normal_eof then  -- check if stream ended because of error
      print ("-- abnormal end of stream: ", error);
   end

   ok,error = zf:close();
   if not ok then
      print ("could not close stream: ", error);
   end

end
