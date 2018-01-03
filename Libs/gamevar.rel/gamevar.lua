--[[
  gamevar.lua
  
  version: 18.01.03
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

-- This may appear pretty awkward, but don't be fooled. This routine has been set up to make it easy to port scripts to other games of mine and also to port those game back here.
-- This also contains features that can help me to easily substitute tags inside routines such as "BoxText" routines. So it does have a lot of advantages.

local vars = { v={} }

assert(Var==nil,"Sorry! GameVar can not be used when the variable Var has been used for something else")

Var = {}
function vars.D(self,tag,value)
    if prefixed(tag,'&') then 
       self.v[tag]=value==true or value:upper(value)=='TRUE'
    elseif prefixed(tag,'%') then
       if type(value)==number then     self.v[tag]=value
       else self.v[tag]=tonumber(value) or 0 end
    elseif prefixed(tag,'$') or prefixed(tag,'_') then
       self.v[tag]=""..value
    else
       error("Unknown tag type: "..tag)
    end
end

function Var.D(tag,value) vars:D(tag,value) end

function vars.G(self,tag)
    return self.v[tag] or 0
end

function Var.G(tag) return vars:G(tag) end

function vars.C(self,tag)
    if prefixed(tag,"&") then
       if self.v[tag] then return 'TRUE' else return 'FALSE' end
    else
       return self.v[tag]..""
    end 
end    

function Var.C(tag) return vars:C(tag) end

function vars.done(self,tag)
    assert(prefixed(tag,"&"),"Done function only works for booleans")
    local ret=self:G(tag)
    self:D(tag,true)
    return ret
end

function Done(tag) return vars:done(tag) end
Var.Done=Done
    
function vars.kill(self,tag)
    self.v[tag]=nil
end

function Var.Kill(tag) vars:kill(tag) end    

function vars.clear(self)
    kv = {}
    for k,_ in pairs(self.v) do kv[#kv+1]=k end
    for k in each(kv) do self:kill(k) end
end    

function Var.Clear() vars:clear() end

function vars.S(self,str) 
   local ret = str
   for k,_ in spairs(self.v) do ret = replace(ret,k,self:C(k)) end
   return ret
end   

function Var.S(str) return vars:S(str) end

function Inc(tag,value) 
    assert( prefixed(tag,"%") , "Inc only works on number values" )
    vars:D(tag,vars:G(tag)+(value or 1))
end

function Dec(tag,value) 
    assert( prefixed(tag,"%") , "Dec only works on number values" )
    vars:D(tag,vars:G(tag)-(value or 1))
end


local gv = { Var=Var, C=Var.C, D=Var.D,Done=Done,S=Var.S,G=Var.G, Kill=Var.Kill, Clear=Var.Clear }
return gv
