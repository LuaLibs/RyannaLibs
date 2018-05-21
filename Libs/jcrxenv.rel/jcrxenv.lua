--[[
  jcrxenv.lua
  
  version: 18.05.21
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
local m={}

local sep=":"
-- $IF $WINDOWS
   sep=";"
-- $FI   

function m.get(v,strict)
    local success,data = JCRXCall({'get',v})
    if strict then assert(success,data)
    elseif not success then return nil end
    return mysplit(data,"\n")[1] -- Make sure no pipe impurities make it through
end

function m.set(key,value)
    local success,e = JCRXCall({'set',key,value})
    assert(success,e)
end

function m.getmulti(v,strict)
    local r = m.get(v,strict)
    if not r then return nil end    
    return mysplit(r,sep)
end    

function m.setmulti(k,v)
    local r=""
    for p in each(v) do
        if r~="" then r = r .. sep end
        r = r .. p
    end
    return m.set(k,r)
end    
    

return m
