--[[
  path.lua
  
  version: 18.05.09
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
local pad = {}

--[[
   These are a few quick path workout routines.
   Please note, that all these routines will only use the UNIX approach to matters.
   That means that pathnames containing BACKSLASHES will have them all changed into NORMAL SLASHES before processing!
]]

local function findlast(haystack,needle)
   local i=#haystack
   local shaystack=replace(haystack,"\\","/")
   while mid(shaystack,i,1)~=needle do 
      i=i-1
      if i<=0 then return nil end
   end
   return i
end   

function pad.DirSplit(filename)
    local a = replace(filename,"\\","/")
    return mysplit(a,"/")
end

function pad.ExtractDir(filename)
   local a = replace(filename,"\\","/")
   local p = findlast(a,"/")    
   if not p then return a end
   return left(a,p)
end

function pad.StripDir(filename)   
   local a = replace(filename,"\\","/")
   local p = findlast(a,"/")    
   if not p then return a end
   return right(a,#a-p)
end

function pad.ExtractExt(filename)
   local a = replace(filename,"\\","/")
   local p = findlast(a,".")    
   if not p then return a end
   if p==1 or (mid(a,p-1,1)=="/") then return a end -- Unix hidden files
   return left(a,p)
end

function pad.StripExt(filename)
   local a = replace(filename,"\\","/")
   local p = findlast(a,".")    
   if not p then return a end
   if p==1 or (mid(a,p-1,1)=="/") then return a end -- Unix hidden files
   return right(a,#a-p)
end



-- Lazy
DirSplit=pad.DirSplit
ExtractDir=pad.ExtractDir   
StripDir=pad.StripDir


return pad
