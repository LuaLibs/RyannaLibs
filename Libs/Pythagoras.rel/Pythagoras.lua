--[[
  Pythagoras.lua
  
  version: 18.01.10
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

local function distancebyPythagoras(x1,y1,x2,y2)
   local side1=math.abs(x1-x2)
   local side2=math.abs(y1-y2)
   local hypothenusa = (side1^2)+(side2^2)
   return math.sqrt(hypothenusa)
end


return distancebyPythagoras



--[[ This routine uses the Pythogean Theorism. >> https://en.wikipedia.org/wiki/Pythagorean_theorem
     The theorism was named after the Greek scientist and philosopher Pythagoras, who was very likely
     the first one who delivered evidence the theorism worked.
     
     And that's why I named this library Pythagoras in his honor. ;)
     
     
     ]]