--[[
  qgfx.lua
  qgfx 
  version: 18.06.02
  Copyright (C) 2016, 2017, 2018 Jeroen P. Broks
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

-- -- (old) *import mkl_version

-- $USE libs/gini


local shit = {}

assets = assets or {}

--[[
mkl.version("Ryanna Libraries - qgfx.lua","18.06.02")
mkl.lic    ("Ryanna Libraries - qgfx.lua","ZLib License")
]]

local imgclass = {}
local function img2class(img)
    for k,v in pairs(imgclass) do img[k]=v end
end    

function WrapImage(image,horizontaal,verticaal)
   for img in each(image.images) do
       img:setWrap(horizontaal,verticaal)
   end
end       


function LoadImage(file,assign,onlynew)
  local ret = { ox = 0, oy = 0, t="image", file=file, setWrap=WrapImage
              }
  img2class(ret)              
  if onlynew and assets[assign] then
     return assign
  end                 
  if type(file)=='string' then
     --print('LoadImage: ',file,assign)
     --if love.filesystem.isDirectory(file:upper()) then
     if JCR_HasDir(file) then
       -- local files = love.filesystem.getDirectoryItems( file:upper() )
       local files = JCR_GetDir(file)
       table.sort(files)
       local l = {}    ret.images = l
       local i,w,h
       for f in each(files) do
           --i = love.graphics.newImage(upper(file.."/"..f))
           if not suffixed(f:upper(),"HOTSPOTS.GINI") then
              i = love.graphics.newImage(JCR_D(f))           
              if i then 
                 l[#l+1]=i
                 w = w or i:getWidth()
                 h = h or i:getHeight()
                 if w~=w or h~=h then return end
              end    
           end
       end
       if #l==0 then return end
       --if love.filesystem.isFile(file:upper().."/HOTSPOTS.GINI") then
       if JCR_Exists(file:upper().."/HOTSPOTS.GINI") then
          local w,h = ret.images[1]:getWidth(),ret.images[1]:getHeight()
          local hgini = ReadIni(file:upper().."/HOTSPOTS.GINI")
          --print(serialize('hotspot_gini',hgini))
          if     hgini:C("X")=="LEFT"   then ret.ox=0
          elseif hgini:C("X")=="RIGHT"  then ret.ox=w
          elseif hgini:C("X")=="CENTER" then ret.ox=w/2
          else   ret.ox = tonumber(hgini:C("X")) or 0 end
          if     hgini:C("Y")=="UP"   or hgini:C("Y")=="TOP"    then ret.oy=0
          elseif hgini:C("Y")=="DOWN" or hgini:C("Y")=="BOTTOM" then ret.oy=h
          elseif hgini:C("Y")=="CENTER"                     then ret.oy=h/2
          else   ret.oy = tonumber(hgini:C("Y")) or 0 end
          --print("Image hotspotted at: ("..ret.ox..","..ret.oy..")")
       end   
     else    
       ret.images = {love.graphics.newImage(JCR_D(file))}
       if not ret.images[1] then return end
     end   
  else 
     ret.images={file} 
  end
  ret.image=ret.images[1] 
  if assign then assets[assign] = ret end        
  return ret
end

function Mark(x,y)
   Line(x-5,y,x+5,y)
   Line(x,y-5,x,y+5)
end             

function LangFont(langarray)
-- // content comes later
end

DrawLine = love.graphics.line
Line     = love.graphics.line


function DrawRect(x,y,w,h,ftype,segs)
love.graphics.rectangle(ftype or "fill",x,y,w,h,segs or 0)
end Rect=DrawRect

local loveversion = {}
loveversion.major,loveversion.minor,loveversion.revision,loveversion.codename=love.getVersion( )
print("QGFX library now running in love version: "..loveversion.major.."."..loveversion.minor.."."..loveversion.revision.." ("..loveversion.codename..")")

if (loveversion.major==0 and loveversion.minor<11) then 
   Color = love.graphics.setColor
   print("Color function copied as the 0-255 scale has been honored")
else
   Color = function(r,g,b,a)
     love.graphics.setColor((r or 255)/255,(g or 255)/255,(b or 255)/255,(a or 255)/255)
   end
   print("Color function set to turn the 0-255 scale into the 0-1 (only to be calculated back for the true calculation, so I wonder who the imbecile is who brought this up!)")
end      

SetColor = Color
color = Color

function white()  Color(255,255,255) end
function black()  Color(  0,  0,  0) end
function red()    Color(255,  0,  0) end
function green()  Color(  0,255,  0) end
function blue()   Color(  0,  0,255) end
function ember()  Color(255,180,  0) end
function yellow() Color(255,255,  0) end

function ColorHSV(h,s,v,a)
   -- $USE libs/hsv
   color(hsv(h,s,v,a)) -- Yes! This works, trust me :P
end
colorhsv=ColorHSV
SetColorHSV=ColorHSV
shit.ColorHSV=ColorHSV
shit.colorhsv=ColorHSV   

shit.LoadImage = LoadImage -- = love.graphics.newImage,love.graphics.newImage
CLS = love.graphics.clear
shit.CLS,shit.cls,shit.Cls,cls,Cls = CLS,CLS,CLS,CLS,CLS

function DrawImage(img,x,y,frame,rad,sx,sy)
local i = (({ ['string'] = function() return assets[img] end,
              ['table']  = function() return img end })[type(img)] or function() error('Unknown image tag type:'..type(img)) end)()
assert(i,"DrawImage("..valstr(img)..","..sval(x)..","..sval(y)..","..(frame or 1).."): I have no image for "..valstr(img))
assert(i.images[frame or 1] , "DrawImage("..valstr(img)..","..sval(x)..","..sval(y)..","..(frame or 1).."): Frame out of bounds - I only have "..#i.images.." frame(s)")
-- This setup does not work the way it should, but that will be sorted out later.               
--love.graphics.push()
--love.graphics.origin(i.ox,i.oy)
love.graphics.draw(i.images[frame or 1],x,y,rad or 0,i.scalex or sx or 1, i.scaley or i.scalex or sy or sx or 1,i.ox or 0, i.oy or 0)
--love.graphics.pop()                   
end 

local function metiImage(self) -- Method iImage
    DrawImage ( self.img,self.x,self.y,self.frame)
end
    
function iImage(img,x,y)
   local im = { img=img,x=x,y=y,frame=0,draw=metiImage }
   return function()
      im.frame=im.frame+1
      if im.frame>#im.images then return nil end
      return im
   end
end

function ImgFrames(image) return #image.images end

function QuadImage(img,quad,x,y,frame)
  local i = (({ ['string'] = function() return assets[img] end,
                ['table']  = function() return img end })[type(img)] or function() error('Unknown image tag type:'..type(img)) end)()
  assert(i,"QuadImage("..valstr(img)..",<quad>,"..x..","..y..","..(frame or 1).."): I have no image for "..valstr(img))
  assert(i.images[frame or 1] , "QuadImage("..valstr(img)..",<quad>,"..x..","..y..","..(frame or 1).."): Frame out of bounds - I only have "..#i.images.." frame(s)")
  love.graphics.draw(i.images[frame or 1],quad,x,y)
end  

function WrapImage(img,hori,verti)
  local i = (({ ['string'] = function() return assets[img] end,
                ['table']  = function() return img end })[type(img)] or function() error('Unknown image tag type:'..type(img)) end)()
  assert(i,"WrapImage("..valstr(img).."): I have no image for "..valstr(img))
  for wimg in each(img.images) do wimg:setWrap(hori,verti) end
end

function ImageSizes(img)
local i = (({ ['string'] = function() return assets[img] end,
              ['table']  = function() return img end ,
              ['nil']    = function() error("I have no image for "..valstr(img)) end }
              )[type(img)])()
local w,h
assert(i,"I have no image for "..valstr(img))
assert(i.images,"It appears this image table has no image frames")
assert(i.images[1],"No frame #1")
w = i.images[1]:getWidth()
h = i.images[1]:getHeight()
return w,h
end
ImageSize=ImageSizes
imgclass.Sizes=ImageSizes


function ImageLoaded(imgtag)
    return assets[imgtag]~=nil
end    

function ImageWidth(img)
  local w,h = ImageSizes(img)
  return w
end
imgclass.width=Imagewidth

function ImageHeight(img)
local w,h = ImageSizes(img)
return h
end
imgclass.height=ImageHeight

function cpImg(img)
local ret = {}
for k,v in pairs(img) do ret[k] = v end
return ret
end

function Hot(img,x,y)
local i = (({ ['string'] = function() return assets[img] end,
              ['table']  = function() return img end })[type(img)])()
i.ox = x or i.ox
i.oy = y or i.oy
end      
imgclass.hot=Hot 

function QHot(img,qtag)
    local iw,ih = ImageSizes(img)
    local hx,hy
    if     qtag=="lt" then hx= 0   hy= 0  
    elseif qtag=='rt' then hx=iw   hy= 0
    elseif qtag=='ct' then hx=iw/2 hy= 0
    elseif qtag=='lc' then hx= 0   hy=ih/2
    elseif qtag=='cc' or
           qtag=='c'  then hx=iw/2 hy=ih/2
    elseif qtag=='rc' then hx=iw   hy=ih/2
    elseif qtag=='lb' then hx= 0   hy=ih
    elseif qtag=='cb' then hx=iw/2 hy=ih
    elseif qtag=='rb' then hx=iw   hy=ih end
    Hot(img,hx,hy)
end    
imgclass.qhot=QHot

function HotCenter(img)
local i = (({ ['string'] = function() assert(assets[img],"No image on: "..img) return assets[img] end,
              ['table']  = function() return img end })[type(img)])()
i.ox=i.image:getWidth()/2
i.oy=i.image:getHeight()/2
end; shit.HotCenter = HotCenter

QText=love.graphics.print
shit.QText=QText
imgclass.hotcenter=hotcenter

function Text2Img(txt,font,hot)
   assert(txt,"No text to convert into an image")
   local td = love.graphics.newText(font,txt)
   local ret = { ox = 0, oy = 0, t="image", file='text:'..txt,
              } 
   ret.image=td
   ret.images={td}
   QHot(ret,hot or 'lt')
   img2class(ret)
   return ret              
end
return shit
