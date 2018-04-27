--[[
  binwrite.lua
  
  version: 18.04.27
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

local function pbyte(bt,b)
    bt.data=bt.data..string.char(b)
end    

local function phnum(bt,n,bytes)
    local b=bytes or 4
    local buf={}
    for i=1,b do buf[i]=0 end
    buf[1]=n
    for i=1,b    do
        while buf[i]>255 do
          assert( i<b,"OVERFLOW!" )
          buf[i+1]=buf[i+1]+1
          buf[i]=buf[i]-255
        end
    end
    for i,byte in ipairs(buf) do bt:putbyte(byte) end
end    

local function pint(bt,b) bt:puthighnum(b,4) end
local function plong(bt,b) bt:puthighnum(b,8) end
local function prs(bt,s) bt.data=bt.data..s end 
local function pstring(bt,s) bt:putint(#s) bt:putrawstring(s) end
local function pbool(bt,b) if b then bt:putbyte(1) else bt:putbyte(0) end end

local function pclose(bt)
   if bt.real then
      local f=io.open(bt.file,"wb")
      f:write(bt.data)
      f:close()
   else
      love.filesystem.write(bt.file,bt.data)
   end
   bt.data=nil -- We no longer need this data, so the sooner it's out of the RAM, the better!   
end

return function(file,real)
    local ret = {}
    ret.data = ""
    ret.file = file
    ret.real = real==true
    -- class functions
    ret.putbyte=pbyte
    ret.puthighnum=phnum
    ret.putint=pint
    ret.putlong=plong
    ret.putrawstring=prs
    ret.putstring=pstring
    ret.putbool = pbool
    ret.writestring=pstring
    ret.writebyte=pbyte
    ret.close=pclose
    return ret
end

