--[[
  bank.lua
  
  version: 18.01.10
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


--[[

    Bank is a "fake"  routine.
    It has been set up for translating BlitzMax or BlitzBasic routines into Lua.
    It will be much easier to just copy the Poke and Peek routines, then having to translate them into true tables.
    
    And that is all there's to it.
    
]]
--[[
-- *import prefsuf

mkl.version("Ryanna Libraries - bank.lua","18.01.10")
mkl.lic    ("Ryanna Libraries - bank.lua","ZLib License")
]]

local function LOADBANKTYPES()
  local list = JCR_GetDir('libs/bank.rel') --love.filesystem.getDirectoryItems( "$$mydir$$" )
  local ret = {}
  for f in each(list) do
    local gn = upper(f)
    if prefixed(f,"TYPE_") and suffixed(f,".LUA") then
       gn = left(gn,len(gn)-4)
       gn = right(gn,len(gn)-5)
       gn = replace(gn,"__IGNORE","")
       print("Initating banktype: "..gn)
       ret[gn]=Use("libs/bank.rel/"..f)
    end
  end
  return ret
end 
local BANKTYPES=LOADBANKTYPES()  



function CreateBank( size, abanktype)
   local banktype=(abanktype or "SIMPLISTIC"):upper()
   local ret = {
                   bank={},
                   banktype=banktype,
                   size = size
               } 
   assert(BANKTYPES[banktype],'I do not know bank type "'..banktype..'"')
   for n,f in pairs(BANKTYPES[banktype]) do
       if type(f)=='function' then ret["_"..n]=f end
   end                  
   if ret._create then ret:_create() end 
   return ret
end

function LoadBank( file, real, abanktype )
   local banktype=(abanktype or "SIMPLISTIC"):upper()
   assert(BANKTYPES[banktype],'I do not know bank type "'..banktype..'"')
   local ret = CreateBank( 0,banktype )
   if ret:_load(file) then return ret else return nil end
end   
   
   
function SaveBank( file,bank,real)
   local s,m = bank:_save(file,bank,real)
   if not s then print ( m ) end
   return s,m
end   


function ResizeBank( bank,newsize )
    bank:_resize( bank, newsize )
end    

      
-- When "real" is true, you can save whever your file system allows you to. If you do not set it then love will decide where to put it in its own protected areas.
-- When you use "real", you must be aware of the several OS's different file system architectures.

function PokeByte(bank,a,b)           bank:_poke_byte(a,b) end
function PokeShort(bank,a,b)          bank:_poke_short(a,b) end
function PokeInt(bank,a,b)            bank:_poke_int(a,b) end
function PokeLong(bank,a,b)           bank:_poke_long(a,b) end

function PeekByte(bank,a)      return bank:_peek_byte(a) end
function PeekShort(bank,a)     return bank:_peek_short(a) end
function PeekInt(bank,a)       return bank:_peek_int(a) end
function PeekLong(bank,a)      return bank:_peek_long(a) end
 
return true 
