-- package object
t2_desc = {}
t2_desc.pkg_desc_format = {}

-- parse .desc text ; expects line iterator function as argument
local function parse(desc)
   local retval = {}

   for line in desc do
      local tag,cnt

      _,_,tag,cnt = string.find(line, "([[][^]]*[]])[ ]+(.*)")
      if tag then
	 local fmt = t2_desc.pkg_desc_format[tag]
	 if fmt then
	    retval[fmt.name] = retval[fmt.name] or {}
	    table.insert(retval[fmt.name], cnt)
	 end
      end
   end

   return retval
end

-- parse .desc file ; expects filename as input
local function parse_file (fname)
   local retval = {}
   printf("Parsing %s...\n", fname)
   return t2_desc.parse( io.open(fname):lines() );
end



-- parse PKG-DESC-FORMAT

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
	 t2_desc.pkg_desc_format[t] = { name = tag; required = required }
      end
   end
end

-- insert methods
t2_desc.parse = parse;
t2_desc.parse_file = parse_file;
