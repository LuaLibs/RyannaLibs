--[[
  fake stringmap.lua
  
  version: 18.01.12
  Copyright (C) 2018 2017
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


--[[

   this routine is fake... Lua doesn't need it at all.
   I used to to make it easier to convert BlitzCode into Lua.
   That's all.
   
   
]]

local function v(self,key) return self.tab[key] end

function newStringMap()
  return { Value = v, value=v, tab={}}
end
NewStringMap=newStringMap
newstringmap=newStringMap  
NewTMap = newStringMap
newtmap = newStringmap



function MapInsert(map,key,value) 
   map.tab[key]=value
   print('Assinged '..sval(value)..' to '..key,"\n"..serialize('map',map))  
end -- This makes convertation from Blitz sooo much easier.

function MapValueForKey(map,key)  return map.tab[key] end 

function MapKeys(map)
  local t={}
  local i=0
  for k,_ in spairs(map.tab) do t[#t+1]=k end
  return function()
      i = i + 1
      return t[i]
  end
end  

function MapValues(map)
  local t={}
  local i=0
  for _,v in spairs(map.tab) do t[#t+1]=v end
  return function()
      i = i + 1
      return t[i]
  end
end  

function MapRemove(map,key)
  map.tab[key]=nil
end

function MapContains(map,key)
  return map.tab  [key] ~= nil
end


function ListContains(list,what)
    for w in each(list) do
        if w==what then return true end
    end
    return false
end

function ListAddLast(list,item)
    list[#list+1]=item
end        
        
return true
