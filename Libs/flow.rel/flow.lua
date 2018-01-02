-- @USE libs/killcallback

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
   acb = a
end

function flow.get(a)
   if a then return byname[a] end
   return currentflow
end

function flow.define(name,flow)
   assert(type(name)=='string',"string expected for the first parameter; not "+type(name))
   assert(type(flow)=='table',"table expected for second paramters; not "+type(flow))
   if byname[name] then flow.undef(name) end
   byname[name]=flow
end

function flow.undef(name)
    libdestroy(byname[name])
    byname[name]=nil
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