--[[
  Scenario.lua
  Scenario reader for Ryanna, based on the reader for GALE based interpreters.
  version: 18.11.24
  Copyright (C) 2016, 2017, 2018 Jeroen P. Broks
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

-- $USE libs/qgfx

local scen={}

local portret = {} scen.portret=portret
local btdata = {} scen.btdata=btdata
function scen.RemoveData(file) btdata = btdata or {} btdata[file] = nil end


local function ProcessBLine(Rec,Prefix,DLine)
local Processes = {
    ["ERROR"] = function() Sys.Error("Unknown scenario prefix") end,  -- error
    ["!"] = function(Rec,DLine) Rec.Header = DLine end,               -- header
    ["*"] = function(Rec,DLine) Rec.PicDir = DLine end,               -- Picture directory
    [":"] = function(Rec,DLine) Rec.PicSpc = DLine end,               -- Picture File
    ["%"] = function(Rec,DLine) Rec.AltTxtFont = "Fonts/"..DLine..".ttf"; CSay("Font: "..DLine)  end, -- Alternate font
    ["#"] = function(Rec,DLine) table.insert(Rec.Lines,DLine) end,    -- content
    ["$"] = function(Rec,DLine) Rec.SoundFile = DLine end,            -- sound (if not present the system will try to autodetect it)
    ["-"] = function() end
    }
local P = Processes[Prefix]
if not P then error("Unknown scenario prefix - "..Prefix) end
P(Rec,DLine)    
end

local function len(a) return #a end

local Image = { -- Faking the original GALE module qith the qgfx routines
   Exists = ImageLoaded,
   Exist = ImageLoaded,
   AssignLoad = LoadImage   
}

function scen.LoadData(file,loadas,merge)
local lang = Var.C("$LANG")
local LineNumber,Line
--local crap = JCR6ListFile("Languages/"..lang.."/Scenario/"..file)
local crap = JCR_Lines('Scenario/'..lang.."/"..file)
local ret = {}
local section = "[rem]"
local L
local Prefix,DLine,WorkRec
--btdata = btdata or {}
if merge then ret = btdata[loadas or file] or {} end 
CSay("Loading BoxText Data: "..file)
for LineNumber,Line in ipairs(crap) do
    L = trim(Line)
    if L~="" then
       if left(L,1)=="[" and right(L,1=="]") then
          section = L
       else
          -- The select statement below is provided through the pre-processor built in the GALE system.
          -- Unfortunately Ryanna has no replacement for the select system (it wasn't so solid in GALE, and that's why I discontinued that).
          -- @SELECT section
          if     section=='[rem]' then -- @CASE   "[rem]"
          elseif section=='[tags]' then -- @CASE   "[tags]"
             ret[L] = {}
          elseif section=='[scenario]' then -- @CASE   "[scenario]"
             Prefix = left(L,1)
             DLine = right(L,len(L)-1)
             -- CSay("ReadLine: "..L.." >> Prefix: "..Prefix) -- Debug line.
             if (not WorkRec) and Prefix~="@" and Prefix~="-" then error("Trying to assign data, while no boxtext record has yet been created in line #"..LineNumber) end
             if Prefix=="@" then
                WorkRec = { Lines = {}, Header="", PicDir="", PicSpc="", SoundFile="" }
                table.insert(ret[DLine],WorkRec)                
             elseif #L>1 then
                ProcessBLine(WorkRec,Prefix,DLine)   
                end
          else -- @DEFAULT
             error("Unknown language section: "..section.." in line #"..LineNumber)   
          end -- @ENDSELECT          
          end
       end
    end
-- Load Images
local k,i,tag,rec
local picfile,picref
for k,tag in pairs(ret) do for i,rec in pairs(tag) do
     picfile = "GFX/Portret/"..sval(rec.PicDir).."/"..sval(rec.PicSpc)..".png"
     --print('picfile',picfile)
     picref = upper(rec.PicDir).."."..upper(rec.PicSpc)
     if (not ImageLoaded(picref)) and JCR_Exists(picfile) then 
        local ti = Image.AssignLoad(picfile,picref) 
        portret[picref]=true 
        CSay('Loaded '..picfile..' on '..picref.." (BoxText)") 
        if not ImageLoaded(picref) then CSay("= FAILED!",255,0,0) end
        if not ti then CSay("= NIL RETURNED",255,0,0) end
     elseif Image.Exist(picref) then
        portret[picref]=true
        end
     if portret[picref] then rec.PicRef=picref; end 
     end end
-- Auto Tie Sound Files
for k,tag in pairs(ret) do for i,rec in pairs(tag) do
    if JCR_Exists("VOCALS/"..file.."/"..k.."_"..i..".ogg") then 
      rec.SoundFile = "Vocals/"..file.."/"..k.."_"..i..".ogg" 
      CSay("Got sound for "..k.." #"..i)
    else
      -- CSay("no sound for "..k.." #"..i.."   (VOCALS/"..file.."/"..k.."_"..i..".ogg)",255,0,0) -- Only annoying. Can be unremmed if needed (which I doubt).  
    end
end end     
-- closure
btdata[loadas or file] = ret    
-- print(serialize("btdata",btdata)) -- Debug Line, must be on rem in release
return ret
end

return scen
