--[[
  qhs.lua
  
  version: 18.01.03
  Copyright (C) 2017, 2018 Jeroen P. Broks
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
-- Strict -- As this is a translation from blitzmax, this line has no value in this translation!

--[[
--- *import mkl_version
mkl.version("Ryanna Libraries - qhs.lua","18.01.03")
mkl.lic    ("Ryanna Libraries - qhs.lua","ZLib License")
]]



function QHD(A,afactor)
  local factor = afactor or 1
  local ret = ""
  local h,t
  for i=1 , #A do
    h = (i-1) * factor -- As BlitzMax works from 0 and Lua from 1, the -1 is needed to maintain compatibility
    t = string.byte(mid(A,i,1)) + h
    while t>255 do t=t-256 end
    while t<  0 do t=t+256 end
    ret=ret..string.char(t)
  end
  return ret
end 

function QUH(a,factor)
  return QHD(a,(factor or 1)*-1)
end

return true
