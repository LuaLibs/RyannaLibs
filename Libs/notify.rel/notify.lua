--[[
  notify.lua
  
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
myapptitle = myapptile or "Maneschijn"

local function notify(message)
   love.window.showMessageBox( myapptitle, message, "info", true )
end


function warn(message)   
   love.window.showMessageBox( myapptitle, message, "warning", true )
end


function throw(message)
    love.window.showMessageBox( myapptitle, message, "error", true )
end

function confirm(question, yes, no) -- the "yes" and "no" parameters can be replaced if your program uses a different language than English.
     local answers={yes=yes or "Yes",no=no or "No"}
     local pressedbutton = love.window.showMessageBox( myapptitle, question, {answers.yes,answers.no,enterbutton=1,escapebutton=2}, "info", true )
     return pressedbutton==1
end


function proceed(question, yes, no,cancel)       
     local answers={yes=yes or "Yes",no=no or "No",cancel=cancel or "Cancel"}
     local pressedbutton = love.window.showMessageBox( myapptitle, question, {answers.yes,answers.no,answers.cancel,enterbutton=1,escapebutton=3}, "info", true )
     if pressedbutton==1 then return 1 end
     if pressedbutton==2 then return 0 end
     if pressedbutton==3 then return -1 end
end

return notify
