--[[
  text.lua
  
  version: 18.03.08
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
local itext = {}
--[[
       This is a simple text module, that will show text based on fonts that are just all png files.
       Coloring effects just just be possible.
       This module can be used for a few things SDL text does not support.
       
       Please note, each letter is only loaded when you need it, unless you force things otherwise.
       Therefore it can slow everything down a little when letters not used before are being asked for. ;)
       
]]

-- $USE libs/qgfx

local currentfont

function itext.loadfont(file,forceall)
     assert(JCR_HasDir(file),"Nothing found on: "..file)
     local ret = { characters={ }, maxheight=0, dir=file }
     return ret
end

function itext.setfont(f) 
    assert(type(f)=="table","expected a font, but I got "..type(f))
    assert(f.characters and f.dir,"Table I got does not look like a font")
    currentfont=f
end    


local function getneededletters(text)
    local ret = {}
    local wait=0
    for i=1,#text do
        if wait>0 then
           wait=wait-1
        elseif mid(text,i,1)=="|" then
           currentfont.characters[mid(text,i,2)] = currentfont.characters[mid(text,i,2)] or LoadImage(dir.."/"..string.byte(mid(text,i+1,1)).."."..string.byte(mid(text,i+2,1))..".png")
           ret[#ret+1]=currentfont.characters[mid(text,i,2)]
           wait=2
        else
            local b = mid(text,i,1):byte()
            currentfont.characters[b] = currentfont.characters[b] or LoadImage(currentfont.dir.."/"..b..".png")
            ret[#ret+1]=currentfont.characters[b]
        end    
    end
    return ret
end

local function sizebygottenletters(letters)
   local w,h=0,0
   for img in each(letters) do
       local iw,ih = ImageSize(img)       
       w = w + iw
       if ih>h then h=ih end
   end
   if h>currentfont.maxheight then currentfont.maxheight=h end
   return w,h
end 

function itext.write(atext,x,y,alh,alv)
    local text=""..atext -- Make sure this is a string... ALWAYS!
    assert(currentfont,"I cannot write text when the font is not yet set")
    local letters = getneededletters(text)
    local w,h=sizebygottenletters(letters) --print('height "'..text.."' is ",w,"x",h) -- debug
    local tx,ty = x,y
    if alh==nil or alh==0 or alh=='l' then tx=x
    elseif         alh==1 or alh=='r' then tx=x-w
    elseif         alh==2 or alh=='c' then tx=x-math.floor(w/2) end
    if alv==nil or alv==0 or alv=='u' then ty=y
    elseif         alv==1 or alv=='d' then ty=y-h
    elseif         alv==2 or alv=='c' then ty=y-math.floor(h/2) end
    for img in each(letters) do
        DrawImage(img,tx,ty)
        tx=tx+ImageWidth(img)
    end    
end

function itext.size(text)
    assert(currentfont,"I cannot write text when the font is not yet set")
    local letters = getneededletters(text)
    local w,h=sizebygottenletters(letters)
    return w,h
end

function itext.width(text)
    local w,h=itext.size(text)
    return w
end      

function itext.height(text)
    local w,h=itext.size(text)
    return h
end      




return itext
