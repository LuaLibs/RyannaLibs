--[[
        Core.lua
	(c) 2018 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.
        Version: 18.01.10
]]

-- $USE libs/errortag

--[[
mkl.version("Ryanna Libraries - Core.lua","18.01.10")
mkl.lic    ("Ryanna Libraries - Core.lua","Mozilla Public License 2.0")

]]
-- $IF $IGNORE
kthura ={}
-- $FI  



local BM={}

function BM.Nada(d,g) return {} end
function BM.Obstacle(d,g) 
    local ret = {}
    kthura.liobj(d)
    local img = d.LoadedTexture.images[1]
    if not img then
       print("WARNING! Obstacle texture "..sval(d.TEXTURE).." was not loaded, so it won't affect the blockmap")
       return {}
    end   
    local w=img:getWidth()
    local h=img:getHeight()
    local gy
    for ix=d.COORD.x-(w/2),d.COORD.x+(w/2) do
        local gx = math.floor(ix/g.x)
        gy = gy or math.floor(d.COORD.y/g.y)
        ret[#ret+1]= gx..","..gy
    end
    return ret
end
function BM.Zone(d,g)
    local ret = {}
    local temp = {}
    for ix=d.COORD.x,d.COORD.x+(d.SIZE.width-1) do for iy=d.COORD.y,d.COORD.y+(d.SIZE.height-1) do
        local gx = math.floor(ix/g.x)
        local gy = math.floor(ix/g.y)
        local s  = gx..","..gy
        if not temp[s] then ret[#ret+1]=s end
        temp[s]=true
    end end
    return ret
end    
BM.TiledArea=BM.Zone


function kthura.remapdominance(map)
   map.dominancemap = {}
   for lay,objl in pairs(map.MapObjects) do for o in each(objl) do
       map.dominancemap[lay] = map.dominancemap[lay] or {}
       local domstring = right("00000000000000000000"..(o.DOMINANCE or 20),5)..right("00000000000000000000"..o.COORD.y,5)
       map.dominancemap[lay][domstring] = map.dominancemap[lay][domstring] or {}
       local m =map.dominancemap[lay][domstring]
       m[#m+1]=o
   end end
end

function kthura.map_block(map,layer,x,y)
   if not map.blockmap then return nil end
   local g = mysplit(map.Grid[layer],"x")
   local gx = tonumber(g[1]) or 1
   local gy = tonumber(g[2]) or 1
   local cx = math.floor(x/gx)
   local cy = math.floor(y/gy)
   return map.blockmap[cx..","..cy]
end   

function kthura.serialblock(map,layer) -- Returns a list of strings, giving a global idea of the blockmap. Only meant for debugging purposes.
  local w=0
  local h=0
  local ks,kw,kh
  local ret ={}
  --kthura.buildblockmap(map)
  --print ( "DEBUG: SERIAL BLOCK CALL")
  --print( serialize("BLOCKMAP",map.blockmap) )
  for k,v in pairs(map.blockmap) do
      ks = mysplit(k,",")
      kw = tonumber(ks[1]) or 0
      kh = tonumber(ks[2]) or 0
      if kw>w then w=kw end
      if kh>h then h=kh end
      print(k)
  end
  for y=0,h do for x=0,w do
      ret[y] = ret[y] or ""
      if map.blockmap[x..","..y] then ret[y] = ret[y] .. "X" else ret[y] = ret[y] .. "." end
  end end
  return ret,w,h
end  

function kthura.buildblockmap(map)
  local p = {{b=true, f='IMPASSIBLE'},{b=false, f="FORCEPASSIBLE"}}  
  local debug = false
  local dchat = function(txt) if debug then print("BUILD KTHURA BLOCKMAP: "..txt) if console then console.write("BUILD KTHURA BLOCKMAP: ",180,0,255) console.writeln(txt,255,255,0) end end end
  map.blockmap = {}    
  for pi in each(p) do for lay,objl in pairs(map.MapObjects) do 
      dchat(pi.f.." "..lay)
      local g = mysplit(map.Grid[lay],"x") 
      local gx = tonumber(g[1]) or 1 local gy = tonumber(g[2]) or 1 
      local grd={x=gx,y=gy} --or 1 
      for o in each(objl) do
         if o[pi.f] then
           local serie = (BM[o.KIND] or BM.Nada)(o,grd)
           for c in each(serie) do map.blockmap[c]=pi.b end
         end
      end   
  end end 
end

function kthura.makeobjectclass(kthuraobject)
     kthuraobject.draw = kthura.drawobject
     kthuraobject.BM = BM[kthuraobject.KIND] or BM.Nada
end

function kthura.makeclass(map)
     for lay,objl in pairs(map.MapObjects) do for o in each(objl) do kthura.makeobjectclass(o) end end
     map.draw = kthura.drawmap
     map.remapdominance = kthura.remapdominance --(map)
     map.buildblockmap = kthura.buildblockmap --(map)
     map.block = kthura.map_block
     map.obj = kthura.obj
end

function kthura.remaptags(map)
  local tm = map.TagMap
  -- I want to keep the original pointer, but I do want to make sure the garbage collector doesn't spook up, as that is an issue in Lua.
  for l,m in pairs(tm) do
      for t,o in pairs(tm) do m[t]=nil end
      tm[l]=nil
  end
  -- And let's now map it out properly
  for lay,objects in pairs(map.MapObjects) do
      tm[lay]={}
      for i,o in pairs(objects) do       
          if o.TAG and o.TAG~="" then          
             assert(not tm[lay][o.TAG],"Duplicate tag in layer: "..lay.."; Tag: "..o.TAG)
             tm[lay][o.TAG]=o
          end
      end    
  end
end

function kthura.obj(map,layer,objtag,musthave)
      local tm = map.TagMap
      local ltm=tm[layer]; assert(ltm,"Layer '"..layer.."' doesn't exist!")
      local ret=ltm[objtag]; if musthave then assert(ret,"Object tag '"..objtag.."' doesn't exist!") end
      return ret
end      
      
function kthura.remapall(map)
    kthura.remapdominance(map)
    kthura.remaptags(map)
    kthura.buildblockmap(map)
end

local actorclass={}

function actorclass:WalkTo(a1,a2)
    local x,y
    if     type(a1)=='number' and type(a2)=='number' then x,y=a1,a2 
    elseif type(a1)=='string' and type(a2)==nil      then
         local map=self.PARENT
         local o=map.TagMap[self.LAYER][a1]
         assert(o,"Trying to walk to non-existent object tag: "..a1)
         x,y=o.COORD.x,o.COORD.y
    else
         error("<actor>.WalkTo(<map>,"..sval(a1)..","..sval(a2).."): Invalid input!")
    end
    local p = FindTheWay(self.COORD.x,self.COORD.y,x,y)
    if p.Success then
        self.walkspot=0
        self.FoundPath = p
        self.walking = true
        self.WalkX = x
        self.WalkY = y
        self.Pathlength = LengthWay(p)
    end         
end

function actorclass:MoveTo(a,b,c)
  local TX,TY,TIgnoreBlocks
  if type(a)=='number' and type(b)=='number' then
     TX,TY,TIgnoreBlocks=a,b,c==true
  elseif type(a)=="string" then
     TIgnoreBlocks=b==true
     local map=self.PARENT
     local o=map.TagMap[self.LAYER][a]
     assert(o,"Trying to move to non-existent object tag: "..a1)
     TX,TY=o.COORD.x,o.COORD.y
  end   
  self.moving = true
  self.MoveX = TX
  self.MoveY = TY
  self.MoveIgnoreBlock = TIgnoreBlocks
end 
  

  



function kthura.Spawn(map,layer,spot,tag,xdata)
    local x,y
    assert(map,errortag('kthura.Spawn',{map,layer,spot,tag,xdata},"No Map"))
    assert(map.MapObjects[layer],errortag('kthura.Spawn',{map,layer,spot,tag,xdata},"Layer not found"))
    if type(spot)=='table' then
       x = spot[1] or spot.x or spot.X or 0
       y = spot[2] or spot.y or spot.Y or 0
    elseif type(spot)=='string' then
       local xspot = map.TagMap[layer][spot]
       assert(xspot,errortag('kthura.Spawn',{map,layer,spot,tag,xdata},"Tried to spawn on an non-existent spot"))
       x = xspot.COORD.x
       y = xspot.COORD.y
    end   
    local actor = {}
    local list = map.MapObjects[layer]
    list[#list+1] = actor
    actor.KIND = "Actor"
    actor.COORD = {x=x,y=y}
    actor.INSERT = {x=0,y=0}
    actor.ROTATION = 0
    actor.SIZE = { width = 0, height = 0 } 
    actor.TAG = tag
    actor.TEXTURE = ""
    actor.CURRENTFRAME = 1
    actor.FRAMESPEED = -1
    actor.ALPHA = 1
    actor.VISIBLE = true
    actor.COLOR = { r = 255, g = 255, b = 255 } 
    actor.IMPASSIBLE = false
    actor.FORCEPASSIBLE = false
    actor.SCALE = { x = 1000, y = 1000 } 
    actor.BLEND = 0
    actor.LAYER = layer -- Needed for typical actor stuff  
    actor.PARENT=map
    kthura.makeobjectclass(actor)
    for k,v in pairs(actorclass) do actor[k]=v end -- Adding the actor methods to the actor
    for k,v in pairs(xdata or {}) do actor[k] = v end
    kthura.remapall(map)
    return actor
end
kthura.spawn=kthura.Spawn

-- Frees the map
-- This MUST always be done, as Kthura map tables DO contain cyclic references that must be un-referenced or due to bugs in the Lua garbage collector you'll get memory leaks.
function kthura.Free(map)
    local debug = true
    local layers = {}    
    map.MapObects = map.MapObjects or {} -- Crash prevention
    map.TagMap = map.TagMap or {} -- Crash prevention
    for layername,layer in pairs(map.MapObjects) do
        layers[#layers]=layername
        if debug then print("Releasing objects in layer: "..layername) end
        local size = #layer
        for obj in each(layer) do            
            obj.PARENT=nil 
        end
        for o=1,size do
            if debug then print("= Releasing object #"..o) end 
            layer[o]=nil 
        end
    end   
    for layername,layer in pairs(map.TagMap) do
        local tm = {}
        for k,_ in pairs(map.TagMap[layername]) do tm[#tm+1]= k end
        for k in each(tm) do 
            if debug then print("= Releasing tag "..k) end
            map.TagMap[layername]=nil 
        end
    end    
    for killlayer in each(layers) do
        map.MapObjects[killlayer]=nil
        map.TagMap[killlayer]=nil
    end 
    local others = {}
    for k,_ in pairs(map) do others[#others+1]=k end
    for k in each(others) do map[k]=nil end 
    -- Only an empty table remains ;)
end
kthura.free=kthura.Free

-- Please note, only maps exported in Lua format can be read.
-- No pure Kthura Maps. This to save resources on Lua engines such as Love
-- and because scripting a JCR6 reader can be problametic too.
function kthura.load(amap,real,dontclass)
   assert(type(amap)=="string",errortag('kthura.load',{amap,real,dontclass},"I just need a simple filename in a string. Not a "..type(amap)..", bozo!"))
   local map = amap:upper()
   if not suffixed(map,".LUA") then map=map..".LUA" end
   local script
   if real then
      local bt = io.open(map,'rb')
      script = bt:read('*all')
      bt:close()
   else
      script = JCR_B(map) --love.filesystem.read(map)
   end
   assert( script, errortag('kthura.load',{amap,real,dontclass},"I could not read the content for the requested map"))
   local compiled = loadstring(script)
   assert ( compiled, errortag('kthura.load',{amap,real,dontclass},"Failed to compile map data"))
   local ret = compiled()
   if not dontclass then kthura.makeclass(ret) end
   kthura.remapdominance(ret)
   return ret   
end

function kthura.loadto(map,amap,real,dontclass)
    assert(map,"LoadTo can only be used with an existing table!!!")
    kthura.Free(map)
    local tempmap = kthura.load(amap,real,dontclass)
    for k,d in each(tempmap) do map[k]=d end
end    
