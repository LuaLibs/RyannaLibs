--[[
  qmath.lua
  
  version: 18.05.26
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
local pythagoras
-- $USE libs/pythagoras
local qm = {}

for k,f in pairs(math) do qm[k]=f end

function qm.Deg2Rad(DEG)
   return DEG * (qm.pi/180)
end

function qm.Rad2Deg(RAD)
   return RAD * (180 / qm.pi)
end       

qm.Distance=pythagoras

qm.rand=random


--[[ I'll sort this one out later... :-/
-- really quick
local rq = ""
for k,_ in pairs(qm) do
    rq = rq .. ("%s = %s or qm.%s\tprint('Convert: %s')\n"):format(k,k,k,k)
end    
load (rq)()
]]

return qm    
