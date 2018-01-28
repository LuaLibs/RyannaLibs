--[[
  optional music.lua
  
  version: 18.01.28
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
local o = {}
local mozart -- will be used to store the music in
local tag = { [true]='one', [false]='two'}
local btag
local pushed = {}


-- 0 = never play music
-- 1 = only play if the music file has been found
-- 2 = always play music and throw an error if we don't have it.
o.use = 1


function o.allow(bool) -- true will set o.use to 2 and false will set it to 0
  if bool then o.use=2 else o.use=2 end
end


o.playing = nil
function o.play(file)
   assert(type(file)=='string','Huh? What do you want me to do! I did expect the name of a music file, not a '..type(file)..' variable.')
   if o.use==0 then return end
   if o.playing==upper(file) then return end
   local got=JCR_Exists(file)
   assert(got or o.use~=2,"Music file '"..file..'" has not been found!')
   if not got then return end
   assert(type(o.swap)=="string","I need you to set the music.swap variable to the name of the swap dir I can use (inside the love work dir). Now I have a '"..type(o.swap).."' value there, whatever that means.")
   local data = JCR_B(file)
   local ds = mysplit(file,".")
   local e = ds[#ds]
   btag = not btag
   local swapmus = o.swap.."/muziek."..tag[btag].."."..e
   local s,m = love.filesystem.write(swapmus,data) data=nil -- save this crap and get rid of it asap!
   assert(s,m)
   if mozart then love.audio.stop(mozart) end
   mozart = love.audio.newSource(swapmus)
   mozart:setLooping(true)
   love.audio.play(mozart)
   o.playing=upper(file)
   
end

function o.push()
   -- if not mozart then return end
   if not o.playing then return end
   pushed[#pushed+1]=o.playing
end

function o.pop()
    if #pushed==0 then return end
    local f = pushed[#pushed]
    pushed[#pushed]=nil
    o.play(f)
end 

o.pull = o.pop    

-- Searches an entire dir and plays a tune at random... ;)
function o.random(dir)
   if o.use==0 then return end
   local got=JCR_HasDir(dir) 
   assert(got or o.use~=2,"Music folder '"..dir.."' has not been found!")
   if not got then return end
   local files = JCR_GetDir(dir)
   local musics = {}
   for f in each(files) do
       local uf=f:upper() 
       if suffixed(uf,".MP3") or suffixed(uf,".OGG") then musics[#musics+1]=f end
   end
   assert(#musics>0,"Cannot randomize empty music folder!") -- There must be at least one file in here recognized as a music file!
   o.play(musics[love.math.random(1,#musics)])
end

   


return o
