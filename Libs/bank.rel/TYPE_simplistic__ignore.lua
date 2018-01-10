--[[
  TYPE_simplistic__ignore.lua
  
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
local function poke(self,a,b) self.bank[a]=b end
local function peek(self,a) return self.bank[a] end


local simple = {
      poke_byte   = poke,
      poke_short  = poke,
      poke_int    = poke,
      poke_long   = poke,
      poke_float  = poke,
      poke_double = poke,
      peek_byte   = peek,
      peek_short  = peek,
      peek_int    = peek,
      peek_long   = peek,
      peek_float  = peek,
      peek_double = peek
      
}


function simple.create(self) self.bank={} end

function simple.load(self,file,real)
    local content
    if real then
      local f = io.open(file, "rb")
            if not f then return false end
            content = f:read("*all")
            f:close()
    else        
      content,size = love.filesystem.read(file)
      if not content then return false end
    end
    local f = loadstring(content)
    if f then
       self.bank,self.size = f()
      
       return true
    else
       return false
    end
end    
    
function simple.save(self,file,data,real)
   local output = serialize('ret',self.bank).."\n\nreturn ret, "..self.size.."\n"
   if real then
      local f = io.open(file,"wb")
      if not fb then return false,"REAL: Could not save to: "..file end
      f:write(output)
      f:close()
      return true,"Ok!"
   else
      return love.filesystem.write(file,output)
   end   
end         

function simple.resize(self,size)
    self.size=size
end    

return simple
