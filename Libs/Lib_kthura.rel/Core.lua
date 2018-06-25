--[[
        Core.lua
	(c) 2018 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.
        Version: 18.06.26
]]

-- $USE libs/errortag
-- $USE libs/nothing

--[[
mkl.version("Ryanna Libraries - Core.lua","18.06.26")
mkl.lic    ("Ryanna Libraries - Core.lua","Mozilla Public License 2.0")

]]
-- $IF $IGNORE
local kthura ={}
-- $FI  

kthura.pathfindwarnings=false -- When you need these warnings, simply turn them back on by making this true
kthura.searcher='DIJKSTRA' -- For now the default searcher. I just had to pick one ;)

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
    --[[
    local ret = {}
    local temp = {}
    for ix=d.COORD.x,d.COORD.x+(d.SIZE.width-1) do for iy=d.COORD.y,d.COORD.y+(d.SIZE.height-1) do
        local gx = math.floor(ix/g.x)
        local gy = math.floor(ix/g.y)
        local s  = gx..","..gy
        if not temp[s] then ret[#ret+1]=s end
        temp[s]=true
    end end
    return ret]]
    local Floor=math.floor
    local Ceil=math.ceil
    local W=d.SIZE.width
    local H=d.SIZE.height
    local X=d.COORD.x
    local Y=d.COORD.y
    local GW,GH=32,32
    local TX = Floor(X/GW)
    local TY = Floor(Y/GH)
    --[[            
    local TW = Floor((X+W)/GW)
    local TH = Floor((Y+H)/GH)
    --]]  
    -- --[[
    local TW = Ceil((X+W)/GW)
    local TH = Ceil((Y+H)/GH)
    --]]
    local s
    local temp = {}
    local ret = {}
    -- Print "DEBUG: Blockmapping area ("+TX+","+TY+") to ("+TW+","+TH+")"
    for AX=TX , TW-1 do
        for AY=TY , TH-1 do
            --Blockmap[ax,ay]=True
            s = AX..","..AY
            if not temp[s] then ret[#ret+1] = s end temp[s]=true 
        end --    Next
    end --      Next
    return ret
end    
BM.TiledArea=BM.Zone

local function numobject(map,layer,obj)
    local num=0
    for i,o in pairs(map.MapObjects[layer]) do
        if o~=obj and (o.idnum or -1)>=num then num=o.idnum+1 end
    end
    obj.idnum=num
end

-- I'll leave this undocumented under all cercumstances as this function is NOT for public use, but otherwise it wouldn't fully work the way it was intended
function kthura.domnum(m,l,obj)
    if not obj.idnum then numobject(m,l,obj) end
    local work = {obj.DOMINANCE or 20,obj.COORD.y, obj.idnum}
    local ret
    for w in each(work) do
        if not ret then ret="" else ret=ret..":" end
        ret = ret .. right("0000000000"..w,10)
    end
    return ret
end
local domnum=kthura.domnum


function kthura.remapdominance(map)
   map.dominancemap = {}
   for lay,objl in pairs(map.MapObjects) do for o in each(objl) do
       map.dominancemap[lay] = map.dominancemap[lay] or {}
       --[[ crap
       local domstring = right("00000000000000000000"..(o.DOMINANCE or 20),5)..right("00000000000000000000"..o.COORD.y,5)
       map.dominancemap[lay][domstring] = map.dominancemap[lay][domstring] or {}
       local m =map.dominancemap[lay][domstring]
       m[#m+1]=o
       ]]      
       local dn = domnum(map,lay,o) -- Must calculate this real time, as this is based on real time parameters which are important, especially with moving actors!
       map.dominancemap[lay][dn] = o
   end end
end

function kthura.remaplabels(map)
     map.labelmap = {}
     for lay,objl in pairs(map.MapObjects) do for o in each(objl) do
         labs = mysplit(o.LABELS,",")
         map.labelmap[lay] = map.labelmap[lay] or {}
         for label in each(labs) do 
             map.labelmap[lay][label] = map.labelmap[lay][label] or {}
             local lm=map.labelmap[lay][label]
             lm[#lm+1]=o
         end
     end end    
end

function kthura.map_block(map,layer,x,y)
   if not map.blockmap then return nil end
   assert(map.Grid[layer],'No Grid mode for layer: '..sval(layer))
   local g = mysplit(map.Grid[layer],"x")
   local gx = tonumber(g[1]) or 1
   local gy = tonumber(g[2]) or 1
   local cx = math.floor(x/gx)
   local cy = math.floor(y/gy)
   return map.blockmap[layer][cx..","..cy]
end   

function kthura.rangeblock(map,layer,sx,sy,ex,ey)
   if sx~=ex and sy~=ey then error("I can only check rangeblocks horizontally and vertically!")
   elseif sx==ex and sy==ey then return kthura.map_block(map,layer,sx,sy) 
   elseif sx<ex and sy==ey then
       for x=sx,ex,1 do
           if kthura.map_block(map,layer,x,sy) then return true end
       end  
   elseif sx>ex and sy==ey then
       for x=ex,sx,1 do
           if kthura.map_block(map,layer,x,sy) then return true end
       end  
   elseif sy<ey and sx==ex then
       for y=sy,ey,1 do
           if kthura.map_block(map,layer,sx,y) then return true end
       end  
   elseif sy>ey and sx==ex then
       for y=ey,sy,1 do
           if kthura.map_block(map,layer,sx,y) then return true end
       end  
  end 
  return false
end   

function kthura.serialblock(map,layer) -- Returns a list of strings, giving a global idea of the blockmap. Only meant for debugging purposes.
  local w=0
  local h=0
  local ks,kw,kh
  local ret ={}
  --kthura.buildblockmap(map)
  --print ( "DEBUG: SERIAL BLOCK CALL")
  --print( serialize("BLOCKMAP",map.blockmap) )
  for k,v in pairs(map.blockmap[layer]) do
      ks = mysplit(k,",")
      kw = tonumber(ks[1]) or 0
      kh = tonumber(ks[2]) or 0
      if kw>w then w=kw end
      if kh>h then h=kh end
      print(k)
  end
  for oy=0,h do for x=0,w do
      local y=oy+1
      ret[y] = ret[y] or ""
      if map.blockmap[layer][x..","..oy] then ret[y] = ret[y] .. "X" else ret[y] = ret[y] .. "." end
  end end
  return ret,w,h
end  

function kthura.buildblockmap(map)
  local p = {{b=true, f='IMPASSIBLE'},{b=false, f="FORCEPASSIBLE"}}  
  local debug = false
  local dchat = function(txt) if debug then print("BUILD KTHURA BLOCKMAP: "..txt) if console then console.write("BUILD KTHURA BLOCKMAP: ",180,0,255) console.writeln(txt,255,255,0) end end end
  map.blockmap = {}    
  map.jumpergrid = {}  
  map.bmsizes = {}
  map.pathfinder = {}
  for pi in each(p) do for lay,objl in pairs(map.MapObjects) do
      map.blockmap[lay] = map.blockmap[lay] or {}
      map.bmsizes[lay] = map.bmsizes[lay] or {width=0,height=0}
      local bms=map.bmsizes[lay]
      dchat(pi.f.." "..lay)
      local g = mysplit(map.Grid[lay],"x") 
      local gx = tonumber(g[1]) or 1 
      local gy = tonumber(g[2]) or 1 
      local grd={x=gx,y=gy} --or 1       
      for o in each(objl) do
         if o[pi.f] then
           local serie = (BM[o.KIND] or BM.Nada)(o,grd)
           for c in each(serie) do 
               map.blockmap[lay][c]=pi.b
               local cs  = mysplit(c,",")
               local csw = tonumber(cs[1]) or 0
               local csh = tonumber(cs[2]) or 0
               if csw>bms.width  then bms.width =csw  end 
               if csh>bms.height then bms.height=csh  end 
           end
           
         end
      end   
      
  map.jumpergrid[lay] = t2Grid(map.blockmap[lay])
  end end 
end

local touchmap = {
     TiledArea = function(obj,x,y) return x>=obj.COORD.x and x<=obj.COORD.x+obj.SIZE.width and y>=obj.COORD.y and y<=obj.COORD.y+obj.SIZE.height end,
     Obstacle = function(obj,x,y)
                   if not obj.LoadedTexture then return false end
                   if y<obj.COORD.y-ImageHeight(obj.LoadedTexture) then return false end
                   if y>obj.COORD.y then return false end
                   local hw = ImageWidth(obj.LoadedTexture)/2
                   return x>=obj.COORD.x-hw and x<=obj.COORD.x+hw
                end
     
}
touchmap.Zone = touchmap.TiledArea
touchmap.Actor = touchmap.Obstacle

function kthura.touch(obj,x,y)
    local tf = touchmap[obj.KIND] or nothing
    return tf(obj,x,y)
end

function kthura.pos(obj)
    return obj.COORD.x,obj.COORD.y
end    

function kthura.makeobjectclass(kthuraobject)
     kthuraobject.draw = kthura.drawobject
     kthuraobject.touch = kthura.touch
     kthuraobject.BM = BM[kthuraobject.KIND] or BM.Nada
     kthuraobject.pos = kthura.pos
end

function kthura.allobjects(map)
    local list = {}
    local i=0
    for lay,objl in spairs(map.MapObjects) do for o in each(objl) do
        list[#list+1]={o=o,l=lay}
    end end
    return function()
       i=i+1
       if not list[i] then return nil,nil end
       return list[i].o,list[i].l
    end
end       

function kthura.showlabels(map,labels,only)
   local lab = labels
   if type(labels)=='string' then lab={labels} end
   for o in kthura.allobjects(map) do
       local v = false
       for l1 in each(mysplit(o.LABELS,",")) do
           for l2 in each(lab) do
               v = v or l1==l2
            end
       end
       if only then
          if v then o.VISIBLE=true end
       else       
          o.VISIBLE=v
       end        
   end
end    

function kthura.hidelabels(map,labels,only)
   local lab = labels
   if type(labels)=='string' then lab={labels} end
   for o in kthura.allobjects(map) do
       local v = false
       for l1 in each(mysplit(o.LABELS,",")) do
           for l2 in each(lab) do
               v = v or l1==l2
            end
       end
       if only then
          if v then o.VISIBLE=false end
       else
          o.VISIBLE=not(v)
       end        
   end
end    


function kthura.makeclass(map)
     for lay,objl in pairs(map.MapObjects) do for o in each(objl) do kthura.makeobjectclass(o) end end
     map.draw = kthura.drawmap
     map.remapdominance = kthura.remapdominance --(map)
     map.buildblockmap = kthura.buildblockmap --(map)
     map.buildlabelmap = kthura.buildlabelmap
     map.remapall = kthura.remapall
     map.block = kthura.map_block
     map.rblock = kthura.rangeblock
     map.obj = kthura.obj
     map.allobjects = kthura.allobjects
     map.showlabels = kthura.showlabels
     map.hidelabels = kthura.hidelabels
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
    kthura.remaplabels(map)    
end

local actorclass={}

local function mgpath(A,x,y)
   return A.PARENT.pathfinder[A.LAYER]:getPath(math.floor(A.COORD.x/32),math.floor(A.COORD.y/32),x,y)
end

function actorclass:WalkTo(a1,a2)
    local x,y
    if     type(a1)=='number' and type(a2)=='number' then x,y=a1,a2 
    elseif type(a1)=='string' and type(a2)=='nil'    then
         local map=self.PARENT
         local o=map.TagMap[self.LAYER][a1]
         assert(o,"Trying to walk to non-existent object tag: "..a1)
         x,y=math.floor(o.COORD.x/32),math.floor(o.COORD.y/32)
    else
         error("["..type(self).." actor]:WalkTo("..type(a1).." "..sval(a1)..","..type(a2).." "..sval(a2).."): Invalid input!")
    end
    if x==0 or y==0 then return false end
    --[[ This is a reference to code that is now officially deprecated!
    local p = FindTheWay(self.COORD.x,self.COORD.y,x,y)
    if p.Success then
        self.walkspot=0
        self.FoundPath = p
        self.walking = true
        self.WalkX = x
        self.WalkY = y
        self.Pathlength = LengthWay(p)
    end         
    ]]
    local parent=self.PARENT
    --if parent.lastjg~=self.LAYER then parent.lastjg=self.LAYER parent.pathfinder
    parent.pathfinder = parent.pathfinder or {}
    parent.pathfinder[self.LAYER] = parent.pathfinder[self.LAYER] or PathFinder(parent.jumpergrid[self.LAYER], kthura.searcher, 0)
    -- This one would crash if a use requests stuff OUTSIDE the field, so let's do that elseway -- self.path = parent.pathfinder:getPath(math.floor(self.COORD.x/32),math.floor(self.COORD.y/32),x,y)
    local pathyes,pathdata = pcall(mgpath,self,x,y)
    if (not pathyes) and kthura.pathfinderwarnings then
       print("WARNING!",pathdata)
       if console then console.write("WARNING! ",255,180,0) console.writeln(pathdata) end
       self.walking=false
       return
    end
    if console and (not self.path ) and kthura.pathfinderwarnings then console.write("WARNING! ",255,180,0) console.writeln("nil received for pathdata") end
    self.path = pathdata
    if not self.path then return false end -- pathfinding failed
    self.nodes ={}
    self.node=1
    local tnodes = {}
    local count=0
    for node, count in self.path:nodes() do
        --count=#self.nodes+1
        tnodes[count]={x=node:getX(),y=node:getY()}
    end
    for i,node in ipairs(tnodes) do            
        if i>1 then --and i<#tnodes then
           local yet = tnodes[i]
           local was = tnodes[i-1]
           -- TrickAssert(was.x,"Invalid data on previous record",{node=count,was=serialize('table',was),yet=serialize('table',yet),fullnodetable=serialize('table',self.nodes)})
           if yet.x~=was.x and yet.y~=was.y then
              local rwas = {x=(was.x*32)-16,y=(was.y*32)-16}
              local ryet = {x=(yet.x*32)-16,y=(yet.y*32)-16}
              if not(parent:rblock(self.LAYER,rwas.x,rwas.y,rwas.x,ryet.y)) then
                 self.nodes[#self.nodes+1]={x=was.x,y=yet.y}
                 --print("Adding vertical correction node: ("..self.nodes[#self.nodes].x..","..self.nodes[#self.nodes].y..")")
              elseif not(parent:rblock(self.LAYER,rwas.x,rwas.y,ryet.x,rwas.y)) then  
                 self.nodes[#self.nodes+1]={x=yet.x,y=was.y}
                 --print("Adding horizontal correction node: ("..self.nodes[#self.nodes].x..","..self.nodes[#self.nodes].y..")")
              end   
           end
        end
        --print("Adding jumper node: ("..node.x..","..node.y..")")
        self.nodes[#self.nodes+1]=node   
    end
    self.walking = #self.nodes>0
    --print("Walk request has "..#self.nodes.." nodes")
    -- print ( serialize('nodes',self.nodes))    
    return self.walking --true
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
  --print('<ACTOR>.MoveTo('..sval(a)..","..sval(b)..","..sval(c)..'):',' Moving to: ('..self.MoveX..","..self.MoveY..")   IgnoreBlocks="..sval(self.MoveIgnoreBlock))
end 
  
actorclass.MoveSkip=4
  



function kthura.Spawn(map,layer,spot,tag,xdata)
    local x,y,labels,dom
    assert(map,errortag('kthura.Spawn',{map,layer,spot,tag,xdata},"No Map"))
    assert(map.MapObjects[layer],errortag('kthura.Spawn',{map,layer,spot,tag,xdata},"Layer not found"))
    if type(spot)=='table' then
       x = spot[1] or spot.x or spot.X or 0
       y = spot[2] or spot.y or spot.Y or 0
       labels = ""
       dom=20
    elseif type(spot)=='string' then
       local xspot = map.TagMap[layer][spot]
       assert(xspot,errortag('kthura.Spawn',{map,layer,spot,tag,xdata},"Tried to spawn on an non-existent spot"))
       x = xspot.COORD.x
       y = xspot.COORD.y
       labels = xspot.LABELS or ""
       dom=xspot.DOMINANCE
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
    actor.LABELS=labels
    actor.DOMINANCE=dom or 20
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
   for layer,obs in pairs(ret.MapObjects) do
       local id=0
       for i,obs in pairs(obs) do obs.idnum=id; id=id+1 end
   end    
   if not dontclass then kthura.makeclass(ret) end
   kthura.remapdominance(ret)
   kthura.remapall(ret)
   return ret   
end

function kthura.loadto(map,amap,real,dontclass)
    assert(map,"LoadTo can only be used with an existing table!!!")
    kthura.Free(map)
    local tempmap = kthura.load(amap,real,dontclass)
    for k,d in each(tempmap) do map[k]=d end
end    
