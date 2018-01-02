--[[
  console.lua
  
  version: 18.01.02
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
local con = {}
local sizes
local stuff = {}

con.stdoutput = false -- if true, all "write" and "writeln" commands will be outputted to stdout as well.

-- Nobody breaks the tradition of CSay!
con.csaycolor = { r=255,g=180,0}
function CSay(text,r,g,b)
  con.writeln(text,r or con.csaycolor.r, g or con.csaycolor.g, b or con.csaycolor.b)
end  


-- if there is a console picture named "GFX/System/Console.png" in the resource, let's load it.
if JCR_Exists("GFX/System/Console.png") then
     -- Yeah, I know there will be a quick graph routine for this, but I don't want the console to be reliant on that, to allow the usage of other libs
     -- Plus this console was set up before this graph routine was adapted for Ryanna.
     print("Loading console background!")
     local data = JCR_B("GFX/System/Console.png")
     local fdata = love.filesystem.newFileData(data,"GFX/System/Console.png")
     con.background = love.graphics.newImage(fdata)     
end

local function loadconfont()
     print("Loading console font")
     local data = JCR_B("Libs/console.rel/cfont/font.ttf")
     local fdata = love.filesystem.newFileData(data,"Libs/console.rel/cfont/font.ttf")
     con.font = love.graphics.newFont(fdata,15)
end loadconfont()

-- Normally you do NOT have to call this yourself, unless you change the forms and shapes of your working window, or even switch to full screen after your first call.
-- If you don't change that after your first call to the console, you're fine.
function con.init()
   local width, height = love.graphics.getDimensions( )
   sizes = { w=width,h=height }
   if con.background then
      con.backquad = love.graphics.newQuad(0,0,width,height,con.background:getWidth(),con.background:getHeight())
      con.backquad:setWrap("repeat","repeat")
   end
end

local function iin() -- init if needed
  if not sizes then con.init() end
end


function con.write(txt,r,g,b,x,y)
  iin()
  con.curx = con.curx or 0
  con.cury = con.cury or 0
  local newstuff = { txt = txt or "", r=r or 0xff, g=g or 0xff, b=b or 0xff, x=x or con.curx, y=y or con.cury}
  newstuff.img = love.graphics.newText( con.font, newstuff.txt )
  if not(x and y) then
    con.curx=(x or con.curx)+newstuff.img:getWidth()
  end
  if con.stdout then print('Console> '..txt) end
  stuff[#stuff+1]=newstuff
end

function con.writeln(txt,r,g,b)
   con.write(txt,r,g,b)
   con.curx = 0
   con.cury = con.cury + 20
   if con.cury>sizes.w-20 then
      con.cury = con.cury - 20
      for stu in each(stuff) do
          stu.y = stu.y - 20
      end
   end
   while stuff[1].y<-40 do table.remove(stuff,1) end
end

function con.show() -- It goes without saying that this should only be calledin a "draw" callback, or things will not go as planned
   iin()
   if con.background then 
      love.graphics.draw(con.background,con.backquad,0,0)
   end
   for st in each(stuff) do
       love.graphics.setColor(st.r,st.g,st.b)
       love.graphics.draw(st.img)
   end     
end

return con
