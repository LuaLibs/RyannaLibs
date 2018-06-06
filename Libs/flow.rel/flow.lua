--[[
  flow.lua
  Flow
  version: 18.06.06
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
-- @USE libs/killcallback
-- @USE libs/nothing

local flow = {}
local byname = {}

local currentflow = {}
local currentflowname

-- Safe method. The flow database can not be destroyed from the main programs calling this.
function flow.flows()
  return byname
end


function flow.set(a)
   if type(a)=='string' then
      assert(byname[a],"There is no flow named "..a)
      currentflowname = a
      return flow.set(byname[a])
   end
   assert(type(a),"Invalid flow type")
   currentflow = a
   currentflowname = a.name or "Unnamed"
   acb = a;
   (a.arrive or nothing)()
end

function flow.get(a)
   if a then return byname[a] end
   return currentflow
end

function flow.undef(name)
    libdestroy(byname[name])
    byname[name]=nil
end

function flow.define(name,flow)
   assert(type(name)=='string',"string expected for the first parameter; not "..type(name))
   assert(type(flow)=='table',"table expected for second parameter; not "..type(flow))
   if byname[name] then flow.undef(name) end
   byname[name]=flow
end


function flow.exists(name)
   return byname[name]~=nil
end   

function flow.use(one,two) -- if two is unset the name of the file will be the name of the flow
    if two==nil then
       local d=mysplit(one,"/")
       local bf=d[#d]
       local e=mysplit(bf,".")
       local tag
       if #e==1 then
          tag=bf
       else
          for i=1,#e-1 do
              if tag then tag=tag.."." else tag = "" end
              tag = tag .. e[i]
          end
       end
       return flow.use(tag,one)
    end
    local f = Use(two)
    flow.define(one,f)
    return f
end       

return flow   
