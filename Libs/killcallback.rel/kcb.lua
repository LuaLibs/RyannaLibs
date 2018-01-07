--[[
  kcb.lua
  
  version: 18.01.07
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
-- $USE libs/nothing

-- $IF $IGNORE
local love = {}
-- $FI

print("Kill Callback") -- This line is just a checkup for me.

local lkeyhit,lskeyhit,lmousehit = {},{},{}

local ltick

acb = {}
quitquestion = quitquestion or "When you quit now any unsaved progress will be lost.\nAre you sure you want to quit?"

keydown = {}
skeydown = {}
mousedown = {}

function love.keypressed(key,scan,rep)
  (acb.keypressed or nothing)(key,scan,rep)
  keydown[key] = true
  skeydown[key] = true
end

function love.keyreleased(key,scan,rep)
  (acb.keyreleased or nothing)(key,scan,rep)
  lkeyhit[key] = ( lkeyhit[key] or 0 ) + 1 
  keydown[key] = false
  skeydown[key] = false
end

function love.mousepressed(x,y,but,touched)
  (acb.mousepressed or nothing)(but,x,y,touched)
  lmousehit[but] = ( lmousehit[but] or 0 ) + 1
  mousedown[but] = true
end

function love.quit()
   if acb.quit then return acb.quit() end
   if quitdontask then return end
   local title = RYANNA_TITLE
   local buttons = {"Yes","No",escapebutton=2}   
   local pressedbutton = love.window.showMessageBox(title, quitquestion, buttons)
   return pressedbutton==2
end   

function love.draw()
   if acb.odraw then
      acb:odraw()
   else
     (acb.draw or nothing)()
  end
end

local updatefuncs = {}

function love.update()
  ltick=true;
  for f in each(updatefuncs) do f() end
  (acb.update or nothing)()
end

function addupdatefunc(f)
    assert(type(f)=='function','updatefuncs must be functions, not '..type(f))
    updatefuncs[#updatefuncs+1]=f
end    

function love.textinput(txt)
  (acb.textinput or nothing)(txt)
end  

function bye()
   quitdontask=true
   love.event.quit()
end   

function keyhit(key)
    local r = lkeyhit[key]
    lkeyhit[key]= nil
    return r
 end
 
 function mousehit(but)
    local r = lmousehit[but]
    lmousehit[but]= nil
    return r
 end


function skeyhit(key)
    local r = lskeyhit[key]
    lskeyhit[key]= nil
 end
 
function flushkeys()
    lkeyhit,lskeyhit,lmousehit = {},{},{}
end

function tick()
    local r = ltick
    ltick = false
    return r
end

return true
