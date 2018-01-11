--[[
  getitall.lua
  
  version: 18.01.11
  Copyright (C) 2018 Jeroen P. Broks
  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:
  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
]]
---------------------------------------------
-- This file will only act as the 'glue'   --
-- between Ryanna and Jumper. I needed     --
-- to do this, because Jumper is set up    --
-- in a way Ryanna is not compatible with. --
--                                         --
-- The RyannaBuild.gini file will see to   --
-- it that Ryanna (ver 18.01.11 or later)  --
-- will ignore all regular settings        --
-- Ryanna normally uses and will pack      --
-- things by the rules of this library     --
--                                         --
-- WARNING! When using this library        --
-- your project may NOT have the folder    --
-- /jumper or things will not work the     --
-- way they should.                        --
--                                         --
-- This library cannot communicate with    --
-- files inside JCR6 parts by itself, but  --
-- it doesn't need to, and Ryanna will     --
-- also NOT respond to preprocessor calls  --
-- aside from those in this file.          --
---------------------------------------------


print([[ This project uses the Yonaba Jumper library

Copyright (c) 2012-2013 Roland Yonaba

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The "glue" code for this library in order to make it usable with the Ryanna
project builder for Love2d was written by Jeroen Broks,.
(c) 2018, Jeroen P. Broks. The glue code has been released under
the terms of the zlib license!
]])

Grid = require("jumper.grid")
PathFinder=require("jumper.pathfinder")


-- These two lines have to protect this library for later overwriting of routines
local Y_Grid=Grid
local Y_Path=Pathfinder

function t2tab_to_2dtab(t,subnil)
     local ret = {}
     local h,w=0,0    
     for k,v in pairs(t) do
         local sk = mysplit(k,",")
         local x=tonumber(sk[1]) or 0
         local y=tonumber(sk[2]) or 0
         if x>w then w=x end
         if y>h then h=y end 
     end
     for y=1,h do for x=1,w do
         ret[y]=ret[y] or {}
         if subnil=='**BOOLNUM**' then
            if t[x..","..y] then ret[y][x]=1 else ret[y][x]=0 end
         else
            ret[y][x]=t[x..","..y] or subnil
         end    
     end end
     return ret    
end

function t2Grid(t,subnil)
    local tb=t2tab_to2dtab(t,subnil or '**BOOLNUM**')
    return Y_Grid(tb)
end

return true
