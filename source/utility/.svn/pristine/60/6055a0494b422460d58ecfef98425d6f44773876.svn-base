/*
 * Copyright (C) 2014-2015 René Rebe, ExactCODE GmbH
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2. A copy of the GNU General
 * Public License can be found in the file LICENSE.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANT-
 * ABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 * 
 * Alternatively, commercial licensing options are available from the
 * copyright holder ExactCODE GmbH Germany.
 */

#include "Lua.hh"

extern "C" {
#include "lstate.h"
}

namespace LuaWrapper {
  
  AutoReleaseItem::AutoReleaseItem(lua_State* L) {
    global_State *g = G(L);
    AutoReleaseItem** autoReleaseList = (AutoReleaseItem**)&(g->ud); 
    
    this->next = *autoReleaseList;
    *autoReleaseList = this;
  }
  
  void runAutoRelease(lua_State* L) {
    global_State *g = G(L);
    AutoReleaseItem** autoReleaseList = (AutoReleaseItem**)&(g->ud); 
    
    while (*autoReleaseList) {
      AutoReleaseItem* next = (*autoReleaseList)->next;
      delete *autoReleaseList;
      *autoReleaseList = next;
    }
  }
  
}
