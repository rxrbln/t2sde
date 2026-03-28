-- --- T2-COPYRIGHT-BEGIN ---
-- t2/misc/luabash/md5/md5.lua
-- Copyright (C) 2006 - 2026 The T2 SDE Project
-- Copyright (C) 2005 Roberto Ierusalimschy
-- SPDX-License-Identifier: GPL-2.0
-- --- T2-COPYRIGHT-END ---

----------------------------------------------------------------------------
-- $Id: md5.lua,v 1.4 2006/08/21 19:24:21 carregal Exp $
----------------------------------------------------------------------------

local core = require"md5.core"
local string = require"string"

module ("md5")

----------------------------------------------------------------------------
-- @param k String with original message.
-- @return String with the md5 hash value converted to hexadecimal digits

function sum (k)
  return (string.gsub(core.dosum(k), ".", function (c)
           return string.format("%02x", string.byte(c))
         end))
end
