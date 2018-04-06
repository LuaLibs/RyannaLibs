--[[
  klok.lua
  klok
  version: 18.04.06
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
local tijd = {}

--[[

     Klok means "clock" in Dutch, and tijd means "time".
     This is just a quick routine with some timer routines made quicker to access.
     No big deal....tijd
     
     ]]
     
     
local function timermethod_wait(self,altmax)
   local t
   repeat
       t = love.timer.getTime()
   until math.abs(t-self.old)>(altmax or self.max or 1)
   self.old=t
end

local function timermethod_passed(self)
   local t = love.timer.getTime()
   return math.abs(t-self.old)
end   

local function timermethod_enough(self,altmax)
   local t = self:passed()
   return t > (altmax or self.max)
end   
     
function tijd:CreateTimer(mtime)
    local ret={
        old = love.timer.getTime(),
        max=mtime,
        wait=timermethod_wait,
        sleep=timermethod_sleep,
        passed=timermethod_passed,
        enough=timermethod_enough
    }
    return ret
end


return tijd         
