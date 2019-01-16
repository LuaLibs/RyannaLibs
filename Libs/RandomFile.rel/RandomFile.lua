--[[
  RandomFile.lua
  Random File
  version: 19.01.16
  Copyright (C) 2019 Jeroen P. Broks
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
return function(param1,param2)
    local list = {}
    local j = jcr
    local prefix = param1
    if param2 then
       if type(param1)=="table" then
          j = param1
          prefix = param2
       elseif type(param1) == "string" then
          j = JCR_Dir(param1)
          prefix = param2
       else
          error(sprintf("RandomPicture(%s,%s): Invalid parameter setup!",param1,param2))
       end
    end
    assert(j     ,sprintf("RandomPicture(%s,%s): I could not get a JCR resource from the given parameters!",param1,param2))
    assert(prefix,sprintf("RandomPicture(%s,%s): I could not get a prefix from the given parameters!",param1,param2))
    assert(type(j.entries)=="table","JCR resource without entries, or entries not properly defined")
    for file,_ in spairs(j.entries) do
        if prefixed(file,prefix:upper()) then list[#list+1]=file end
    end
    -- CSay(serialize("FileFist",list)) -- debug
    return list[math.random(1,#list)]
end    
