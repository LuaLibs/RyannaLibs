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
  if not sizes then init() end
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
end



return con