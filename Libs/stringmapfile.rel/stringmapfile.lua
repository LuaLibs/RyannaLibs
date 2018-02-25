--[[
  stringmapfile.lua
  
  version: 18.02.25
  Copyright (C) 2017, 2018 Jeroen P. Broks
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

-- These tags were used in the old love builder, but this has now been re set up for Ryanna.
-- BuildLove -- *import binread
-- BuildLove -- *import qhs 

-- $USE libs/binwrite
-- $USE libs/binread
-- $USE libs/qhs

function readstringmap(file,pure)
    local bt=binread(file,pure)
    local ret = {}
    local tag,factor,k,v
    repeat
        if bt:eof() then return ret end -- please note closure is not required!
        local tag = bt:getbyte()
        if tag==255 then return ret end
        if tag==2 then 
           factor=bt:getbyte()
           k = QUH(bt:getstring())
           v = QUH(bt:getstring())
           ret[k]=v
        elseif tag==1 then
           k = bt:getstring()
           v = bt:getstring()
           ret[k]=v
        else
           error("Unknown tag in readstringmap.\nFile: "..file.."\bTag:  "..tag)
        end
    until false    
end

function writestringmap(smap,file,real)
    local bt=binwrite(file,real)
    if smap.Value and type(smap.Value)=='function' and type(smap.tab)=='table' then return writestringmap(smap.tab,file,real) end 
    for k,v in spairs(smap) do
        bt:putbyte(1)
        print(type(v),k,"=",v)
        assert(type(v)=='string' or type(v)=='number',"writestringmap([table],'"..file.."',"..sval(real)..'): Key '..k..' is a '..type(v)..' and I only want strings!')
        bt:writestring(k)
        bt:writestring(v)
    end
    bt:putbyte(0xff)
    bt:close()
end        

--[[
mkl.version("Ryanna Libraries - stringmapfile.lua","18.02.25")
mkl.lic    ("Ryanna Libraries - stringmapfile.lua","ZLib License")
]]

return true
