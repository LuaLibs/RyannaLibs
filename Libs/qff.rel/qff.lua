--[[
  qff.lua
  
  version: 18.05.21
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
local me = {}

function me.filetype(pfile)
    local file=pfile
    if prefixed(file,"~/") then file=os.getenv("HOME")..right(file,#file-2) end
    local success,dat = JCRXCall({'type',file})
    dat = trim(dat)
    if success then return dat end
    if suffixed(dat,"no such file or directory") then return "non-existent" end
    return nil
end

function me.isdir(file)
  return me.filetype(file)=='directory'
end

function me.isfile(file)
  return me.filetype(file)=='file'
end

function me.exists(file)
   local r=me.filetype(file)
   return r~=nil and r~="non-existent" 
end           

me.IsDir=me.isdir
me.IsFile=me.isfile
me.Exists=me.exists

return me
