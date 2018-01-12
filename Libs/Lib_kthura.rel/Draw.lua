--[[
        Draw.lua
	(c) 2017, 2018 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.
        Version: 18.01.06
]]

-- $USE Libs/qgfx

--[[
mkl.version("Ryanna Libraries - Draw.lua","18.01.06")
mkl.lic    ("Ryanna Libraries - Draw.lua","Mozilla Public License 2.0")
]]

-- $IF $INOGRE
kthura ={}
-- $FI  


kthura.showzones = false -- Should only be true when debugging.

local loadedtextures = {}

local function genloadtexture(o)
   loadedtextures[o.KIND] = loadedtextures[o.KIND] or {}
   local lto = loadedtextures[o.KIND]
   local tfl = o.TEXTURE:upper()
   --print("Loading Texture: "..tfl)
   lto[tfl] = lto[tfl] or LoadImage(tfl)
   return lto[tfl]
end

local function niets() end

local function animate(o)
   if o.FRAMESPEED==-1 then return end
   --print(serialize("Animated object",o)) -- Debug line. Since it slows the system down, this must always be on comment when not needed!
   --print("TIME:"..sval(o.FRAMETIME).."; TICK:"..sval(o.FRAMETIMETICKVALUE).."; ROLL:"..sval(o.FRAMEROLL).."; FRAME:"..sval(o.FRAME).."; FRAMEMAX:"..sval(#o.LoadedTexture.images))
   local t = love.timer.getTime()
   o.FRAMETIME = o.FRAMETIME or t 
   o.FRAMETIMETICKVALUE = math.abs(t-o.FRAMETIME)
   if o.FRAMETIMETICKVALUE<.05 then return end
   o.FRAMETIME = t
   o.FRAMEROLL = (o.FRAMEROLL or o.FRAMESPEED) - 1
   if o.FRAMEROLL<=0 then
      o.FRAMEROLL=nil
      o.FRAME = (o.FRAME or 1) + 1
      if #o.LoadedTexture.images<o.FRAME then o.FRAME=1 end
   end   
end

local function ktcolor(o)
   Color(o.COLOR.r,o.COLOR.g,o.COLOR.b,255*o.ALPHA)
end

local drawclass = {

    Pic = {
        draw = function(self,camx,camy)
           animate(self)
           ktcolor(self)
           self.X = self.COORD.x
           self.Y = self.COORD.y
           if self.SIZE.width==0 or self.SIZE.height==0 then
              DrawImage(self.LoadedTexture,self.X-(camx or 0),self.Y-(camy or 0),self.FRAME,self.ROTATION,self.SCALE.x/1000,self.SCALE.y/1000)
           else
              local pw,ph=ImageSizes(self.LoadedTexture)
              for x=0,self.SIZE.width-1 do for y=0,self.SIZE.height-1 do
                 local mdx=x*pw
                 local mdy=y*ph
                 DrawImage(self.LoadedTexture,(mdx+self.X)-(camx or 0),(mdy+self.Y)-(camy or 0),self.FRAME,self.ROTATION,self.SCALE.x/1000,self.SCALE.y/1000)
              end end
           end   
        end
    },    
    Obstacle = {
       LoadTexture=function(o)
          local r = genloadtexture(o)
          local w,h = ImageSizes(r)
          Hot(r,w/2,h)
          return r
       end,
       draw = function(self,camx,camy)
           animate(self)
           ktcolor(self)
           self.X = self.COORD.x
           self.Y = self.COORD.y
           -- --[[
           if self.SIZE.width==0 or self.SIZE.height==0 then
              DrawImage(self.LoadedTexture,self.X-(camx or 0),self.Y-(camy or 0),self.FRAME,self.ROTATION,self.SCALE.x/1000,self.SCALE.y/1000)
           --[[else]] end
           --]]
           --[[
              local pw,ph=ImageSizes(self.LoadedTexture)
              for x=0,self.SIZE.width-1 do for y=0,self.SIZE.height-1 do
                 local mdx=x*pw
                 local mdy=y*ph
                 DrawImage(self.LoadedTexture,(mdx+self.X)-(camx or 0),(mdy+self.Y)-(camy or 0),self.FRAME,self.ROTATION,self.SCALE.x/1000,self.SCALE.y/1000)
              end end
           --end      
           ]]       
       end,
    },
    Zone = { -- Here everyhting just has to be empty
       LoadTexture=niets,
       draw=function(o) end
    
    },
    Actor = {
       LoadTexture=function (a)
            local r = genloadtexture(a)
            local tx = a.TEXTURE:upper()
            if (love.filesystem.isDirectory(tx) and (love.filesystem.isFile(tx.."/HOTSPOINTS"))) or love.filesystem.isFile(tx) then
               Hot(r,w/2,h)
            end
            return r
       end,
       draw=function(self,camx,camy)
           local ABX,ABY,TBX,TBY,AcX,AcY,GoX,GoY,GoW
           local cnode
           local Floor = math.floor
           local map=self.PARENT
           if self.anim or self.moving or self.walking then
              animate(self)
           end
           ktcolor(self)
           local ax = self.COORD.x - (camx or 0)
           local ay = self.COORD.y - (camy or 0)
           --DrawImage(self.LoadedTexture,ax,ay,self.FRAME,self.ROTATION,self.SCALE.x/1000,self.SCALE.y/1000)
           local A=self
           
           -- Walker calculations
           if A.walking and (not A.moving) then 
              ABX = Floor(self.COORD.x/32) --(A.X/A.parent.BlockmapgridW)
              ABY = Floor(self.COORD.y/32) --(A.Y/A.parent.BlockmapgridH)
              cnode=A.nodes[A.node]    TBX,TBY=cnode.x,cnode.y --ReadWaySpot A.FoundPath,A.WalkSpot,TBX,TBY
              --'Print "ABX = "+ABX+"; TBX = "+TBX+"; ABY = "+ABY+"; TBY = "+TBY+"; Spot = "+A.WalkSpot+"; Length = "+LengthWay(A.FoundPath) ' debugline
              if ABX==Floor(TBX) and ABY==Floor(TBY) then
                 A.node = A.node + 1 -- A.WalkSpot:+1
                 A.walking=A.node<#A.nodes -- A.Walking = A.WalkSpot<=LengthWay(A.FoundPath)
              end --EndIf
              if A.walking then
                 cnode=A.nodes[A.node]    TBX,TBY=cnode.x,cnode.y --   ReadWaySpot A.FoundPath,A.WalkSpot,TBX,TBY        
                 AcX = (ABX*32) + 16 -- (abX*A.Parent.BlockMapGridW)+(A.Parent.BlockMapGridW/2)
                 AcY = ((ABY+1)*32) -2  -- ((abY+1)*A.Parent.BlockMapGridH)-1
                 GoX = (TBX*32)+16 -- (tbX*A.Parent.BlockMapGridW)+(A.Parent.BlockMapGridW/2)
                 GoY = ((TBY+1)*32) -2 -- ((tbY+1)*A.Parent.BlockMapGridH)-1
                 --'print "ABX = "+ABX+"; TBX = "+TBX+"; ABY = "+ABY+"; TBY = "+TBY+"; Spot = "+A.WalkSpot+"; Length = "+LengthWay(A.FoundPath)+" AcX = "+AcX+"; GoX = "+GoX+"; AcY = "+AcY+"; GoY = "+GoY ' debugline
                 if ABX~=TBX then
                    A:MoveTo(GoX,AcY,1)
                    -- 'Print "Going to "+GoX+","+AcY+" Moving Horizontally"
                 elseif ABY~=TBY then
                    A:MoveTo(AcX,GoY,1)
                    --'Print "Going to "+AcX+","+GoY+" Moving Vertically"
                 end -- EndIf
              end --EndIf         
           end --EndIf
           
           -- Mover calculations
           if A.moving then
               for ak=1,A.MoveSkip do -- For ak=0 Until A.Moveskip
                   local labs=mysplit(A.LABELS  or "",",") -- Local labs$[] = O.Labels.split(",")
                   local domstring = kthura.domnum(A.PARENT,A.LAYER,A) -- right("00000000000000000000"..(A.DOMINANCE or 20),5)..right("00000000000000000000"..A.COORD.y,5)
                   --[[ temporary out of use
                   for L in each(labs) do -- For Local L$=EachIn labs
                       -- MapRemove A.parent.TagMapByLabel.Get(Trim(L),True),Hex(A.dominance)+"."+Hex(+A.Y)+"."+Hex(A.idnum)
                   end ]] --Next
                   map.dominancemap[A.LAYER][domstring]=nil --MapRemove A.parent.Drawmap,Hex(A.dominance)+"."+Hex(A.Y)+"."+Hex(A.idnum)                  
                   GoX=A.COORD.x
                   GoY=A.COORD.y
                   GoW=A.WIND
                   if A.MoveY<A.COORD.y then GoY=A.COORD.y-1; GoW="North" end
                   if A.MoveY>A.COORD.y then GoY=A.COORD.y+1; GoW="South" end
                   if A.MoveX<A.COORD.x then GoX=A.COORD.x-1; GoW="West"  end
                   if A.MoveX>A.COORD.x then GoX=A.COORD.x+1; GoW="East"  end
                   if A.MoveIgnoreBlock or (not A.PARENT:block(A.LAYER,GoX,GoY)) then
                      A.COORD.x=GoX
                      A.COORD.y=GoY
                      A.WIND = GoW
                   else
                      A.moving=false --' Destination is blocked.
                   end --EndIf
                   if A.COORD.x==A.MoveX and A.COORD.y==A.MoveY then A.moving=false end -- We reached the destination
                   --[[ temp out of use
                     labs = O.Labels.split(",")
                     For Local L$=EachIn labs
                         MapInsert A.parent.TagMapByLabel.Get(Trim(L),True),Hex(A.dominance)+"."+Hex(+A.Y)+"."+Hex(A.idnum),A
                     Next
                   ]]  
                   domstring = kthura.domnum(A.PARENT,A.LAYER,A) -- right("00000000000000000000"..(A.DOMINANCE or 20),5)..right("00000000000000000000"..A.COORD.y,5) --MapInsert A.parent.Drawmap,Hex(A.dominance)+"."+Hex(+A.Y)+"."+Hex(A.idnum),A
                   map.dominancemap[A.LAYER][domstring]=A
               end -- Next
           end -- EndIf 
       --DrawImage I,A.X-x,A.Y-y,A.Frame
       ax = self.COORD.x - (camx or 0)
       ay = self.COORD.y - (camy or 0)       
       DrawImage(self.LoadedTexture,ax,ay,self.FRAME,self.ROTATION,self.SCALE.x/1000,self.SCALE.y/1000)
       end
    
    },
    TiledArea = {
         LoadTexture = function(o)
            local r = genloadtexture(o)
            for i in each(r.images) do
                i:setWrap('repeat','repeat')
            end
            local iw,ih = ImageSizes(r)
            o.QUAD = love.graphics.newQuad(0-o.INSERT.x,0-o.INSERT.y,o.SIZE.width,o.SIZE.height,iw,ih)    
            return r
         end,
         draw = function(o,cx,cy)
            animate(o)
            ktcolor(o)
            QuadImage(o.LoadedTexture,o.QUAD,o.COORD.x-cx,o.COORD.y-cy)
         end
    },
    Exit = {LoadTexture=niets,draw=niets}    

}


function kthura.liobj(self) -- Load Image Object
     -- local c = drawclass[self.KIND]
     local camx,camy=0
     assert(self.KIND,errortag("kthura.drawobject",{self,camx,camy}," Object has no kind"))
     local c = drawclass[self.KIND]
     assert(c,errortag("kthura.drawobject",{self,camx,camy}," kind '"..self.KIND.."' not supported in this version of the Kthura Drawing Engine"))
     self.LoadedTexture = (c.LoadTexture or genloadtexture)(self)
end

function kthura.drawobject(self,camx,camy)
     assert(self.KIND,errortag("kthura.drawobject",{self,camx,camy}," Object has no kind"))
     local c = drawclass[self.KIND]
     assert(c,errortag("kthura.drawobject",{self,camx,camy}," kind '"..self.KIND.."' not supported in this version of the Kthura Drawing Engine"))
     self.LoadedTexture = (c.LoadTexture or genloadtexture)(self)
     c.draw(self,camx,camy)    
end


function kthura.drawmap(self,layer,camx,camy)
    --[[ test code
    if type(layer)=='string' then 
       for o in each(self.MapObjects[layer]) do 
           if not o.draw then kthura.classobject(o) end
           if o.VISIBLE then o:draw(camx,camy) end
       end        
    elseif type(layer)=='table' then
       for o in each(layer) do
           if not o.draw then kthura.classobject(o) end
           if o.VISIBLE then o:draw(camx,camy) end
        end
    
    else
       error(errortag("kthura.drawmap",{},"Illegal layer ("..type(layer)..")"))    
    end
    ]]
    assert(self.MapObjects[layer],errortag('kthura.drawmap',{self,layer,camx,camy},"Invalid layer"))
    if not self.dominancemap then
       print("WARNING! Dominance was not mapped. This must be done before drawing so let's do that now anyway") 
       kthura.remapdominance(self) 
    end
       for dk,o in spairs(self.dominancemap[layer]) do
         --[[
         if not dm then print("It's not right... let's investigate") for k,v in pairs(self.dominancemap[layer]) do print(type(v),k) end end
         TrickAssert(type(dm)=='table','Dominance map corrupted with type '..type(dm).." on #"..sval(dk).."! Expected a table.")
         for o in each(dm) do]] 
           if not o.draw then kthura.classobject(o) end
           if o.VISIBLE then o:draw(camx,camy) end
         --end  
       end            
end
