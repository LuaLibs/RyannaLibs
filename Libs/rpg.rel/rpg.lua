--[[
  rpg.lua
  
  version: 18.02.25
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

----------------------------------------------------------------------------------------
-- This code was originally written in BlitzMax.
-- It's roughl translated to Lua in order to be used with the Love engine.
-- Please note, that since BlitzMax is a compiler based language, I could
-- back then not fully take advantage of the power a scripting language like
-- Lua provides. The opposite holds also true.
-- BlitzMax doesn't care about upper and lower case either and Lua does, oh crap!
-- 
-- This translation will therefore not be the most efficient code you've 
-- ever seen, but I felt no need either to re-invent the wheel.
----------------------------------------------------------------------------------------

--[[
Strict
Import tricky_units.StringMap
Import gale.multiscript
Import gale.Main
Import jcr6.jcr6main
Import jcr6.zlibdriver
Import tricky_units.MKL_Version
Import tricky_units.TrickyReadString
Import tricky_units.jcr6stringmap
Import brl.max2d

MKL_Version "Tricky's Units - RPGStats.bmx","17.08.13"
MKL_Lic     "Tricky's Units - RPGStats.bmx","Mozilla Public License 2.0"
]]


-- $USE Libs/console
-- $USE Libs/stringmap

local GALE_MS = {} -- Used to 'fake' a GALE MS environment
 
-- Private
local Chat=true -- Const Chat = True
--Public
MustHavePortrait = True

-- Global RPGJCR:TJCRDir
RPGJCRDir = ""

RPGID = ""
RPGEngine = ""

-- Private
local function ConsoleWrite(M,R,G,B)
   console.writeln(M,R or 255,G or 255,B or 255)
   -- (M$,R=255,G=255,B=255) L_ConsoleWrite M,R,G,B End Function
end   
--Public

--[[Rem
bbdoc: If set to 'true' the lua scripts tied to a stat will be ignored. (Most of meant for quick viewers)
End Rem]]

RPG_IgnoreScripts = false

-- Type RPGPoints
function NewRPGPoints()
  local ret = {}
  ret.Have,ret.Maximum,ret.Minimum=0,0,0 --Field Have,Maximum,Minimum
  ret.MaxCopy = ""
  
  function ret:Inc(a) self.Have=self.Have + (a or 1) end
  function ret:Dec(a) self.Have=self.Have - (a or 1) end
  return ret
end --  End Type

function NewRPGStat() -- Type RPGStat
  local ret ={} 
  ret.Pure = 0
  ret.ScriptFile=""
  ret.CallFunction=""
  ret.Value=0
  ret.Modifier=0
  function ret:Inc(value) self.Value = self.Value + (value or 0) end
  function ret:Dec(value) self:Inc(-(value or 0)) end
  return ret
end  
  
--[[Rem
bbdoc: Contains character data.
End Rem]]
function NewRPGCharacter() -- Type RPGCharacter
  local ret = {}
  ret.Name = ""
  --'Field StrData:StringMap = New StringMap
  ret.StrData = {} --Field StrData:TMap = New TMap
  ret.Stats = {} -- Field Stats:TMap = New TMap
  ret.Lists = {} -- Field Lists:TMap = New TMap
  ret.Points = {} -- Field Points:TMap = New TMap
  ret.PortraitBank = {} -- Field PortraitBank:TBank -- This one will not be really worked out fully. It was never used fully in the BlitzMax games either.
  ret.Portrait = nil -- Field Portrait:TImage -- Just there for cleanness sake!
  
  function ret:Stat(st) --Method Stat:RPGStat(St$)
      return self.Stats[st]
  end      
  
  function ret:List(lst) -- Method List:TList(lst$)
      return self. Lists[lst] -- Return TList(MapValueForKey(Lists,lst))
  end -- End Method
  
  function ret:Point(p) -- Method Point:RPGPoints(p$)
      return self.Points[p] -- Return rpgpoints(MapValueForKey(Points,p))
  end -- End Method
  
  return ret
  
end --  End Type

RPGChars = {} -- Global RPGChars:TMap = New TMap
RPGParty = {} -- Global RPGParty$[] = New String[6]


--[[Rem
returns: The character data tied to the requested tag
End Rem]]
function GrabChar(ch) -- Function GrabChar:RPGCharacter(Ch$)
    return RPGChars[ch] -- Return RPGCharacter(MapValueForKey(rpgchars,ch))
end -- End Function
grabchar = GrabChar

--[[ Since this was deprecated, I am not gonna transfer it, but I'll let it die in stead! :P
Type TMe ' Deprecated
  Field Char$,Stat$
  End Type
  ]]

--Private
--'Type linkeddata
--' Field c1$,c2$,d$
--' End Type
--'Global linkeddatalist:TList = New TList
local function NewTRPGData() -- Type TRPGData
  --Field d$
  return {d=""}
end -- End Type
  
local function dstr(A) --:StringMap(A:TMap)
 -- local k="" -- Local k$
 local ret = NewStringMap() -- Local ret:StringMap = New StringMap
 for k,_ in spairs(A) do
   MapInsert(ret,k,A[k]) -- TRPGData(MapValueForKey(A,k)).d
 end --  Next
 return ret
end -- End Function
function ddat(A) -- Function ddat:TMap(A:StringMap)
 -- local k
 local ret= {} --  ret:TMap = New TMap
 local t -- :TRPGData
 for k in MapKeys(A) do -- For k=EachIn MapKeys(A)
  t = NewTRPGData()
  t.d = A.value(k)
  ret[k]=t -- MapInsert ret,k,t
 end -- Next
 return ret
end -- End Function

-- Public

-- Originall meant for the Lua API in LAURA II, but now they can serve for quick functions anyway, so I can easily return that for this library ;)
local api = {} -- Type RPGLuaAPI -- ' BLD: Object RPGChar\nThis object contains features you need for RPG Character and statistics
  
  --Field Me:TMe = New TMe ' --- no doc. This is deprecated, and not to be used. I only left it in the source to prevent compiler errors. Old BLD desc: Variable with the fields Char and Stat. They can both be used to read the current character and stat being processed. It's best to never assign any data to this. These vars are only to be used by the scripts being called by Stat readers.
  
  function api:NewParty(MaxChars) -- Method NewParty(MaxChars) -- ' BLD: Creates a new party. If MaxChars is not set the default value 6 will be used. There is no "official" limit to the maximum amount of characters in a party, it's just how much memory you have.<p>If you never use this function you have a party of max 6 characters available.
    local m = 6
    if maxchars then m=maxchars end
    if maxchars<0 then error("Negative max party") end
    RPGParty = {} --  New String[m]
  end -- End Method
  
  function api:ClearParty() -- Method ClearParty() -- ' BLD: Removes all characters from the party
     -- For Local ak=0 Until Len(RPGParty) RPGParty[ak]="" Next
     local remove = {}
     for k,_ in pairs(RPGParty) do remove[#remove+1]=k end
     for k in each(remove) do RPGParty[k]=nil end
  end -- End Method
  
  function api:RemoveFromParty(Tag) -- Method RemoveFromParty(Tag$) -- ' BLD: The character with the tag specified will be removed from the party and the party will automatically remove the empty spaces.
  local P = {} -- Local P$[] = New String[Len(RPGParty)]
  local c = 0
  -- Local ak
  for ak,_ in ipairs(RPGParty) do -- =0 Until Len(RPGParty)
    if RPGParty[ak]~=Tag and RPGParty[ak]~="" then 
      P[c] = RPGParty[ak]
      c=c+1 --:+1
    end--  EndIf
  end --  Next
  RPGParty = P
  end -- End Method
  
  
  function api:PartyTag(pos) -- Method PartyTag$(pos) -- ' BLD: Returns the codename of a character on the specific tag
     if RPGParty[pos] then return "***ERROR***" end
     return RPGParty[pos]
  end -- End Method
  
  function api:ReTag(characterold,chracternew) -- Method ReTag(characterold$,characternew$) -- ' BLD: The tag of a party member will be changed.<br>If this character is currently in the party, the party will automatically be adapted.<br>Please note, if a character already exists at the new tag, it will be overwritten, so use this with CARE!
    local ch=grabchar(characterold) -- Local ch:RPGCharacter = grabchar(characterold$)
    if not ch then return error("Original character doesn't exist\nF,RPGChar.ReTag("..characterold..","..characternew..")") end
    RPGChars[characternew]=ch--MapInsert RPGChars,characternew,ch
    RPGCHars[characterold]=nil -- MapRemove RPGChars,characterold
    for i,_ in pairs(RPGParty) do -- Local i=0 Until Len RPGParty
      if RPGParty[i]==characterold then RPGParty[i]=characternew end
    end --Next
  end -- End Method  
  
  function api:SetParty(pos,Tag) -- Method SetParty(pos,Tag$) -- ' BLD: Assign a party member to a slot. Please note depending on the engine there can be a maximum of slots.
    -- If pos>=Len(RPGParty) Return
    RPGParty[pos] = Tag
  end -- End Method
  
  --[[ Not use (yet)
  Method Portrait(Char$,x,y) -- ' BLD: Show a character picture if it exists.
  local ch = grabchar(char)
  If Not ch GALE_Error("Character doesn't exist",["F,RPGChar.Portrait","char,"+char])
  If ch.Portrait DrawImage ch.Portrait,x,y 'Else Print "No picture on: "+Char
  End Method
  ]]

  function api:TrueStat(char,stat) -- Method TrueStat:RPGStat(char$,stat$) ' The true stats and its values. This is not documented as using this is pretty dangerous and should only be done when you know what you are doing.
    local ch=grabchar(char) -- local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.TrueStat\nchar="..char)
  
    local ST = ch:Stat(stat) -- ST:RPGStat = ch.stat(stat)
    assert( ST, "Stat doesn't exist\nRPGChar.TrueStat\nchar="..char.."\nStat="..stat)
    return ST
  end -- End Method
  
  function api:CountChars() -- BLD: Returns the number of characters currently stored in the memory. (Not necesarily the amount of party members) :)
     local cnt = 0
     for k,v in pairs(rpgchars) do cnt=cnt+1 end
     return cnt
  end -- End Method
  
  --[[ Not needed in pure Lua
  Method CharByNum$(index) -- ' BLD: Returns the name of the character found at index number 'index'.<P>This function has only been designed for iteration purposes, and can better not be used if you are not sure what you are doing. If the index number is "out of bounds", an empty string will be returend. The first entry is number 0.
  Local ret$
  Local cnt = 0
  For Local k$ = EachIn MapKeys(rpgchars) 
    If cnt=index Return k
    cnt:+1 
    Next
  End Method
  ]] 
  
  function api:Stat(char,stat,nomod) -- Method Stat(Char$,Stat$,nomod=0) -- ' BLD: Returns the stat value
   local ch=grabchar(char) -- ):RPGCharacter = grabchar(char)
   local csr=""
   local lua = ".lua"
   assert ( ch ,"Character doesn't exist\nRPGChar.Stat\nchar="..char.."\nStat="..stat)
   local st = ch:Stat(stat) -- :RPGStat = ch.stat(stat)
   assert(st  ,"Stat doesn't exist\nRPGChar.Stat\nchar="..char.."\nStat="..stat)
   if st.ScriptFile and st.ScriptFile~="" and st.CallFunction and (not RPG_IgnoreScripts) then 
    --Me.Char = Char
    --Me.Stat = Stat
    csr = "CHARSTAT:"..upper(st.ScriptFile)
    if suffixed(st.ScriptFile:upper(),".LUA") then  lua="" end   
    if not GALE_MS[csr] then GALE_MS[csr]=Use((RPGJCRDIR or "SCRIPT/RPGCHARS/")..st.ScriptFile) end -- If Not GALE_MS.ContainsScript(csr) GALE_MS.Load(csr,RPGJCRDIR+st.Scriptfile+lua)
    assert( GALE_MS[csr] , (RPGJCRDIR or "SCRIPT/RPGCHARS/")..st.ScriptFile..lua.." not loaded correctly!")
    assert( GALE_MS[csr][st.CallFunction], "Function "..st.CallFunction.." not found!\ncsr="..csr.."\nChar="..char.."\nStat="..stat)
    st.Value=GALE_MS[csr][st.CallFunction](char,stat)
    return st.Value --GALE_MS_Run csr,st.callfunction,[Char,Stat]
    -- Me = New TMe
   end--  EndIf   
   local nomodint
   if nomod then nomodint=0 else nomodint=1 end 
   return st.Value + (st.Modifier * nomodint)
  end -- End Method
  
  function api:SafeStat(Char,Stat,nomod) -- Method SafeStat(Char$,Stat$,nomod=0) -- ' BLD: Returns the stat value, but would the normal Stat() method crash the game if a character or stat does not exist, this one will then return 0
   local ch = grabchar(char)
   if not ch then return 0 end
   if ch:Stat(Stat) then return self:Stat(Char,Stat,nomod) else return 0 end  
  end -- End Method
  
  function api:DefStat(char,stat,avalue,OnlyIfNotExist) -- Method DefStat(char$,Stat$,value=0,OnlyIfNotExist=0) -- ' BLD: Defines a value. Please note that if a stat is scripted the scripts it refers to will always use this feature itself to define the value. If "OnlyIfNotExist" is checked to 1 or any higher number than that, the definition only takes place of the stat doesn't exist yet. This was a safety precaution if you want to add stats later without destroying the old data if it exists, but to create it if you added a stat which was (logically) not yet stored in older savegames.
   local ch = grabchar(char)
   local value=avalue or 0
   assert( ch , "Character doesn't exist\nRPGChar.DefStat\nchar="..char.."\nStat="..stat.."\nValue="..value)
   local st = ch:Stat(stat)
   if not (ch.Stats[stat]) then
    st = NewRPGStat()
    ch.Stats[stat]=st --MapInsert ch.Stats,stat,st
   elseif OnlyIfNotExist then
    return
   end -- End If    
   st.Value=value
  end -- End Method
  
  function api:NewStat(char,stat,value) -- Method NewStat(char$,Stat$,Value) -- ' BLD: Shortcut to DefStat with OnlyIfNotExist defined ;)
    api:DefStat(char,stat,balue,true)
  end -- End Method
  
  function api:StatExists(char,stat) -- Method StatExists(char$,Stat$) -- ' BLD: Returns 1 if the stat exists, returns 0 if stat does not exist
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.Stat\nchar="..char)
   return ch:Stat(stat)~=nil
  end -- End Method

  
  function api:LinkStat(sourcechar,targetchar,statname) -- Method LinkStat(sourcechar$,targetchar$,statname$) -- ' BLD: The stat of two characters will be linked. This means that if one stat changes the other will change and vice versa. Upon this definition, the targetchar's stat will be overwritten. After that the targetchar or the sourcechar do not matter any more, they will basically share the same stat. (This feature came to be due to its need in Star Story) :)<p>Should the targetchar's stat not exist it will be created in this function.
   local ch1 = grabchar(sourcechar)
   assert(ch1,"LINKSTAT:  SOURCE Char doesn't exist> "..sourcechar) --If Not ch1 GALE_Error("Source Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+statname])
   local ch2 = grabchar(targetchar)
   assert(ch2,"LINKSTAT:  TARGET Char doesn't exist> "..targetchar) -- If Not ch2 GALE_Error("Target Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+statname])
   local ST = ch1:Stat(statname)
   assert(ST,"Source Character's stat doesn't exist\nRPGChar.LinkStat\nsourcechar="..sourcechar.."\ntargetchar="..targetchar.."\nstat="..statname)
   ch2.Stats[statname]=ST -- MapInsert ch2.Stats,statname,ST
  end -- End Method

  function api:LinkList(sourcehcar,targetchar,statname) -- Method LinkList(sourcechar$,targetchar$,statname$) -- ' BLD: The list of two characters will be linked. This means that if one list changes the other will change and vice versa. Upon this definition, the targetchar's stat will be overwritten. After that the targetchar or the sourcechar do not matter any more, they will basically share the same stat. (This feature came to be due to its need in Star Story) :)<p>Should the targetchar's stat not exist it will be created in this function.
   local ch1 = grabchar(sourcechar)
   assert(ch1,"LINKLIST:  SOURCE Char doesn't exist> "..sourcechar) --If Not ch1 GALE_Error("Source Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+statname])
   local ch2 = grabchar(targetchar)
   assert(ch2,"LINKLIST:  TARGET Char doesn't exist> "..targetchar) -- If Not ch2 GALE_Error("Target Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+statname])
   local ST = ch1:List(statname)
   assert(ST,"Source Character's stat doesn't exist\nRPGChar.LinkList\nsourcechar="..sourcechar.."\ntargetchar="..targetchar.."\nstat="..statname)
   ch2.lists[statname]=ST -- MapInsert ch2.Stats,statname,ST
  end -- End Method
  
  --[[
      Method SetStat(char$,Stat$,value=0,OnlyIfNotExist=0) -- ' BLD: Alias for DefStat
  DefStat(char$,Stat$,value,OnlyIfNotExist) 
  End Method
  ]] api.StatStat = api.DefStat
  
  function api:ScriptStat(char,stat,script,func) -- Method ScriptStat(char$,stat$,script$,func$) -- ' BLD: Define the script for a stat. Please note, if either the script or the function is not properly defined the system will ignore the scripting.
   local ch = grabchar(char)
   assert ( ch,"Character doesn't exist\nRPGChar.ScriptStat\nchar="..char)
   local st = ch:Stat(stat)
   if not st then error("Stat doesn't exist\nRPGChar.ScriptStat\nChar="..char.."\nStat="..stat) end
    st.ScriptFile = script
    st.CallFunction = func
    -- Print -- ?? 
  end -- End Method
  
  --[[ The fact that I never noticed I never set this damn function, means that I never missed or needed it, so I doubt I'll need it now. I wish I could remember what I had in mind back then....
  Method ModStat(char,stat,modifier) -- ' BLD: Set the modifier
  End Method
  ]]
  
  function api:SetName(char,name) -- -- ' BLD: Name the character
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.SetName\nchar="..char)
   ch.Name = name  
  end -- End Method
  
  function api:GetName(char) -- BLD: Retrieve the name of a character
  local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.GetName\nchar="..char)
   return ch.Name
  end -- End Method
  
  function api:SetData(char,key,str) -- -- ' BLD: Define data in a character
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.GetName\nchar="..char)
   local td -- :trpgdata 
   if ch.StrData[key] then -- If MapContains(ch.strData,key) 
    td = ch.StrData[key] -- trpgdata(MapValueForKey(ch.strdata,key))
   else
    td = NewTRPGData(); 
    ch.StrData[key]=td -- MapInsert ch.strdata,key,td
   end -- EndIf
   td.d=str
  end -- End Method
  api.DefData=api.SetData -- BlitzMax didn't take this, but Lua does _:

  function api:DataExists(char,key) -- Method DataExists(char$,key$) -- ' BLD: Returns 1 if exists, and 0 if it doesn't
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.DataExists\nchar="..char)  --'Local td:trpgdata 
   return ch.StrData[key]~=nil -- MapContains(ch.strData,key) 
  end -- End Method

    
  function api:NewData(char,key,str) -- Method NewData(Char$,key$,str$) -- ' BLD: If a data field does not exist, create it and define it. If it already exists, ignore it! (1 is returned if a definition took place, 0 is returned when no definition is done)
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.NewData\nchar="..char)
   if not ch.StrData[key] then api:SetData(char,key,str) return true end  --If Not MapContains(ch.strdata,key) SetData char,key,str; Return True   
   return false
  end -- End Method
  
  --[[ Let's do this elseway :P
  Method LinkData(sourcechar$,targetchar$,dataname$) -- ' BLD: The stat of two characters will be linked. Works similar to LinkStat but then with Data.
  Local ch1:RPGCharacter = grabchar(sourcechar)
  If Not ch1 GALE_Error("Source Character doesn't exist",["F,RPGChar.LinkData","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+dataname])
  Local ch2:RPGCharacter = grabchar(targetchar)
  If Not ch2 GALE_Error("Target Character doesn't exist",["F,RPGChar.LinkData","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+dataname])
  Local ST:trpgdata = trpgdata(MapValueForKey(ch1.strdata,dataname))
  If Not ST GALE_Error("Source Character's data doesn't exist",["F,RPGChar.LinkData","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+dataname])
  MapInsert ch2.strdata,dataname,ST 
  End Method]]
  function api:LinkData(sourcechar,targetchar,statname) -- Method LinkList(sourcechar$,targetchar$,statname$) -- ' BLD: The list of two characters will be linked. This means that if one list changes the other will change and vice versa. Upon this definition, the targetchar's stat will be overwritten. After that the targetchar or the sourcechar do not matter any more, they will basically share the same stat. (This feature came to be due to its need in Star Story) :)<p>Should the targetchar's stat not exist it will be created in this function.
   local ch1 = grabchar(sourcechar)
   assert(ch1,"LINKDATA:  SOURCE Char doesn't exist> "..sourcechar) --If Not ch1 GALE_Error("Source Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+statname])
   local ch2 = grabchar(targetchar)
   assert(ch2,"LINKDATA:  TARGET Char doesn't exist> "..targetchar) -- If Not ch2 GALE_Error("Target Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+statname])
   local ST = ch1.StrData[statname]
   assert(ST,"Source Character's stat doesn't exist\nRPGChar.LinkData\nsourcechar="..sourcechar.."\ntargetchar="..targetchar.."\nstat="..statname)
   ch2.StrData[statname]=ST -- MapInsert ch2.Stats,statname,ST
  end -- End Method
  

  
  --'Method DefData(Char$,K$,S$) Setdata Char,K,S End method
  
  function api:GetData(char,key) -- Method GetData$(char$,key$) -- ' BLD: Retrieve the data in a character
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.GetData\nchar="..char)
   --'Return ch.strdata.value(key)
   local td=ch.StrData[key]-- :trpgdata = trpgdata(MapValueForKey(ch.strdata,key))
   if not td then return "" end
   return td.d
  end -- End Method
  
  api.Data = api.GetData -- Method Data$(c$,k$) Return GetData(C,K) End Method
  
  function api:DelStat(char,stat) -- -- ' BLD: Delete a stat in a character
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.DelStat\nchar="..char)
    if not ch.Stats[stat] then -- MapContains(ch.stats,stat) 
      ConsoleWrite("DelStat: WARNING! Character "..char.." does not HAVE a stat named: "..stat)
      return
    end -- EndIf
    ch.stats[stat]=nil --MapRemove ch.stats,stat
  end -- End Method
--[[  
  Method DelData(char$,key$) -- ' BLD: Delete data in a character  
  local ch = grabchar(char)
  If Not ch 
    GALE_Error("Character doesn't exist",["F,RPGChar.DelData","char,"+char])
    EndIf
  MapRemove ch.strdata,key
  End Method
]]
   function api:DelData(char,key)
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.DelData\nchar="..char)
    if not ch.StrData[key] then -- MapContains(ch.stats,stat) 
      ConsoleWrite("DelStat: WARNING! Character "..char.." does not HAVE a data slot named: "..stat)
      return
    end -- EndIf
    ch.StrData[key]=nil --MapRemove ch.stats,stat
   end 

  
  function api:CharExists(char) -- BLD: Returns 1 if the character exists and returns 0 if it doesn't.<p>Always remember that 0 does count as "true" in Lua.
   return grabchar(char)~=nil
  end -- End Method
  
  -- In the original this was a string separated by ;, but that was because MaxLua could not push tables to Lua. Now that we are using "pure" Lua, things are different. ;)
  function api:CharList() -- Method CharList$(Char$) -- ' BLD: Retuns a string with all codenames of the loaded chars separated by ;
   local ret = {} -- Local ret$
   for k,_ in spairs(RPGChars) do --For Local k$=EachIn MapKeys ( RPGChars )
    --If ret ret:+";"
    ret[#ret+1]=k --ret:+k
   end -- Next
   return ret
  end -- End Method
  
  function api:CreateChar(char) -- Method CreateChar(Char$) -- ' BLD: Create a character (if a character already exists under that name, it will simply be deleted).
    RPGChars[char]=NewRPGCharacter()--MapInsert RPGChars,Char,New RPGCharacter
    ConsoleWrite ("Character '"..char.."' has been created")
  end --End Method
  
  function api:DelCharacter(char) -- BLD: Deletes a character
  local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.DelChar\nchar="..char)
  RPGChars[char]=nil--MapRemove rpgchars,char 
  end --End Method
  
  api.DelChar=api.DelCharacter --[[
  Method DelChar(char$) -- ' BLD: Alias for DelCharacter. Some people (like me) are just lazy.
  delcharacter char
  End Method]]
  
  function api:CreateList(char,List) -- BLD: Create a list, but don't add any items yet
   self:AddList(char,list,"POEP")
   self:ClearList(char,list)
  end -- End Method
  
  function api:AddList(char,list,item) ---- ' BLD: Create a list inside a character record. If the requested list does not yet exist, this function will create it.
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.AddList\nchar="..char)
    if not ch:List(list) then ch.Lists[list]={} end --MapInsert ch.lists,List,New TList
    local tl=ch.Lists[list] tl[#tl+1]=item --ListAddLast ch.list(list),Item
  end -- End Method
  
  function api:RemList(char,list,item) ---- ' BLD: Remove an item from a list
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.AddList\nchar="..char)
    local ls = ch.List(list)
    assert( ls ,"List doesn't exist=nRPGChar.AddList\nchar="..char.."\nList,"..list)
    --ListRemove ls,item
    local kill
    repeat
        local kill=nil
        for i,v in ipairs(ls) do if v==item then kill=i end end
        if kill then table.remove(ls,kill) end
    until not kill
  end -- End Method
  
  function api:ClearList(char,list) -- BLD: Empty a list
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.AddList\nchar="..char)
   local ls = ch.List(list)
   assert(ls ,"List doesn't exist\nRPGChar.ClearList\nchar="..char.."\nList="..list)
   -- brl.linkedlist.ClearList ls
   local c=#ls
   for i=1,c do ls[i]=nil end 
  end -- End Method
  
  function api:CountList(char,list) -- BLD: Count the number of entries in the list
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.Countist\nchar="..char)
    local ls = ch.List(list)
    assert(ls , "List doesn't exis\nRPGChar.CountList\nchar="..char.."\nList="..list)
    return #ls -- brl.linkedlist.CountList(ls)
  end -- End Method
  
  function api:ValueList(Char,list,Index) ---- ' BLD: Return the value at the index. <br>This routine has been adepted to Lua starting with 1 and ending on the max number!
   --Return PureValueList(Char$,List$,Index-1)
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.CountList\nchar="..char)
    local ls = ch.List(list)
    assert(ls , "List doesn't exis\nRPGChar.ValueList\nchar="..char.."\nList="..list)
    return ls[Index] -- brl.linkedlist.CountList(ls)
  end-- End Method
  
  --[[ In pure Lua this one is no longer needed
  Method PureValueList$(Char$,List$,Index)
  local ch = grabchar(char)
  If Not ch GALE_Error("Character doesn't exist",["F,RPGChar.PureValueList","char,"+char,"List,"+List])
  Local ls:TList = ch.list(list)
  If Not ls GALE_Error("List doesn't exist",["F,RPGChar.PureValueList","char,"+char,"List,"+List])
  If index>=brl.linkedlist.CountList(ls) GALE_Error("List index out of range",["char,"+char,"List,"+List,"Pure Index,"+Index,"Lua Index,"+Int(Index+1)])
  Return String(ls.valueatindex(index))
  End Method  
  ]]
  
  function api:DestroyList(char,list) -- BLD: Destroy the list
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.DestroyList\nchar="..char)
    --Local ls:TList = ch.list(list)
    -- If Not ls GALE_Error("List doesn't exist",["F,RPGChar.DestroyList","char,"+char,"List,"+List])
    --MapRemove ch.lists,list
    ch.Lists[list]=nil
  end --End Method
  
  --[[
  Rem
  Method ListLen(Char$,List$) ' -- BLD: Return the number of items in a list. If the list doesn't exist it returns 0.
  local ch = grabchar(char)
  If Not ch GALE_Error("Character doesn't exist",["F,RPGChar.CountList","char,"+char,"List,"+List]); Return 0
  Local ls:TList = ch.list(list)
  If Not ls Return 0
  Return CountList(ls)
  End Method
  End Rem
  
    
  Method ListItem$(char$,List$,Index) -- ' BLD: Return the item at an index on the list. When the index number is too high an error will pop up.<p>Please note, the api in this method has been adepted to Lua, so it starts with 1, and ends with the countnumber of the list. 0 is therefore not taken as a valid index! Always remember it!
  local ch = grabchar(char)
  If Not ch GALE_Error("Character doesn't exist",["F,RPGChar.CountList","char,"+char,"List,"+List])
  Local ls:TList = ch.list(list)
  If Not ls GALE_Error("List doesn't exist",["F,RPGChar.CountList","char,"+char,"List,"+List])
  If index<1 Or index>CountList(char,list) GALE_Error("List index out of bounds!",["F,RPGChar.Listitem","Char,"+char,"List,"+list,"Index,"+Index,"Allowed rage,1 till "+CountList(char,list)])
  Local TrueIndex = Index - 1
  Return String(ls.valueatindex(TrueIndex))
  End Method
  ]]
  api.ListLen=api.CountList
  api.ListItem=api.ValueList
  
  
  function api:ListExist(char,list) -- BLD: returns 1 if the character and the list tied to that character exist otherwise it returns 0
    local ch = grabchar(char)
    if not ch then return false end
    if ch.lists[list] then  return 1 end
  end --End Method
  
  function api:PointsExists(char,points)
   local ch = grabchar(char)
   if not ch then 
     ConsoleWrite("WARNING! PointsExist(~q"+Char+"~q,~q"+points+"~q): Character doesn't exist. Returning False anyway",255,180,0)
     return false
   end -- EndIf
   return ch.Points[points]~=nil - MapContains(ch.points,points)
  end--End Method
    
  function api:Points(char,points,docreate) -- Method Points:RPGPoints(char$,points$,docreate=0) -- ' BLD: Points. Has two fields. "Have" and "Maximum". These can be used for Hit Points, Mana, Skill Points, maybe even experience points. Whatever. There is also a field called "MaxCopy" which is a string. When you copy this field, the system will always copy the value of the stat noted in this string for the Maximum value. When the value "docreate" is set to 1 the system will create a new value if it doesn't exist yet, when it's set to 2, it will always create a new value and destroy the old, any other value will not allow creation and cause an error if the points do not exist.
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.Points\nchar="..char)
    --Select DoCreate
    if docreate==1 or docreate==true then
      if not ch.Points[points] then  ch.Points[points]=NewRPGPoints() end
    elseif docreate==2 then 
     ch.Points[points]=NewRPGPoints()
    elseif docreate==255 then
      if not ch.Points[points] then return nil end -- Null ' value 255 is not documented as it's used internally, and usage in Lua would most likely lead to crashes without a proper error message.  
    end -- End Select
   local p=ch.Points[points] --p:RPGPoints = RPGPoints(MapValueForKey(ch.points,points))
   assert(p,"Points could not be retrieved\nRPGChar.Points\nChar="..char.."\nPoints="..points.."\nDoCreate"..sval(docreate))
   --'Print "Points call: "+char+","+Points+","+DoCreate+";     p.Have="+p.have+"; p.Maximum="+p.Maximum+"; p.maxcopy="+p.MaxCopy
   if p.MaxCopy and p.MaxCopy~="" then
      p.Maximum = self:Stat(char,p.MaxCopy)
   end-- EndIf
   if p.Have>p.Maximum then p.Have=p.Maximum end
   if p.Have<p.Minimum then p.Have=p.Minimum end
   if p.Minimum>p.Maximum then error("Points minimum bigger than maximum! How come?\nChar="..char.."\nPoints="..points.."\nMinimum="..p.Minimum.."\nMaximum.."..p.Maximum) end
   return p
  end --End Method
  
  function api:LinkPoints(sourcechar,targetchar,pointsname) -- BLD: The stat of two characters will be linked. This means that if one stat changes the other will change and vice versa. Upon this definition, the targetchar's stat will be overwritten. After that the targetchar or the sourcechar do not matter any more, they will basically share the same stat. (This feature came to be due to its need in Star Story) :)<p>Should the targetchar's stat not exist it will be created in this function.
  --[[
   Local ch1:RPGCharacter = grabchar(sourcechar)
    If Not ch1 GALE_Error("Source Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+pointsname])
    Local ch2:RPGCharacter = grabchar(targetchar)
    If Not ch2 GALE_Error("Target Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+pointsname])
    Local ST:RPGPoints = Points(sourcechar,pointsname)
    If Not ST GALE_Error("Source Character's points doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+pointsname])
    MapInsert ch2.Points,pointsname,ST
    ]]
     local ch1 = grabchar(sourcechar)
     assert(ch1,"LINKDATA:  SOURCE Char doesn't exist> "..sourcechar) --If Not ch1 GALE_Error("Source Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+statname])
     local ch2 = grabchar(targetchar)
     assert(ch2,"LINKDATA:  TARGET Char doesn't exist> "..targetchar) -- If Not ch2 GALE_Error("Target Character doesn't exist",["F,RPGChar.LinkStatStat","sourcechar,"+sourcechar,"targetchar,"+targetchar,"stat,"+statname])
     local ST = ch1.Points[pointsname]
     assert(ST,"Source Character's points doesn't exist\nRPGChar.LinkPoints\nsourcechar="..sourcechar.."\ntargetchar="..targetchar.."\nstat="..statname)
     ch2.Points[pointname]=ST -- MapInsert ch2.Stats,statname,ST
  end  --End Method

  function api:IncStat(char,Statn,value) ---- ' BLD: Increases a stat by the given number. If value is either 0 or undefined, the stat will be increased by 1
    local v=value or 1
    if v==0 then v=1 end
    api:DefStat(char,statn,api:Stat(char,statn)+v)
  end --End Method

  function api:DecStat(char,Statn,value) -- BLD: Decreases a stat by the given number. If value is either 0 or undefined, the stat will be decreased by 1
    api:Inc(char,Statn,0-(value or 1))
  end --[[  
  Local v=value
  If v=0 v=1
  DefStat char,statn,stat(char,statn)-v
  End Method]]
  
  function api:StatFields(char) -- Method StatFields$(char$) -- ' BLD: Returns a string with all statistics fieldnames separated by ";". It is recommended to use a split function to split it (if you don't have one I'm sure you can find some scripts for that if you google for that).
   local ret={}
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.StatFields\nchar="..char)
   for k,_ in spairs(ch.Stats) do
    --If ret ret:+";"
    ret[#ret+1] = k
   end -- Next
  return ret
  end -- End Method

  function api: ListFields(char) -- BLD: Returns a string with all list fieldnames separated by ";". It is recommended to use a split function to split it (if you don't have one I'm sure you can find some scripts for that if you google for that).
  local ret = {}
  local ch = grabchar(char)
  assert( ch ,"Character doesn't exist\nRPGChar.ListFields\nchar="..char)
  for k,_ in spairs(ch.Lists) do
    ret[#ret+1] = k
   end -- Next
  return ret
  end -- End Method
  
  function api:ListHas(char,list,itemstring) -- BLD: returns 1 if the item was found in the list. If the list or the item does not exist it returns 0
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.ListHas\nchar="..char)
    local l=ch.Lists[list]; if not l then return end
    for i,v in ipairs(l) do 
        if v==itemstring then return true end
    end
    return false -- ListContains(ch.list(list),itemstring)
  end --End Method
  
  function api:ListOut(char,list) -- Method ListOut$(char$,list$,separator$=";") -- ' BLD: Puts all item sof a list in a string diveded by ; by default, unless you set a different separator
   --If Not separator separator=";"
   --local ret={}
   local ch = grabchar(char)
   assert( ch ,"Character doesn't exist\nRPGChar.ListOut\nchar="..char)
   local l=ch.Lists[list]; if not l then return end --If Not MapContains(ch.lists,list) Return
   return l --[[For Local i$ = EachIn ch.list(list)
    If ret ret:+";"
    ret:+i
  Next
  Return ret
  End Method    ]] end
  
  
  function api:DataFields(char) -- BLD: Returns a string with all stringdata fieldnames separated by ";". It is recommended to use a split function to split it (if you don't have one I'm sure you can find some scripts for that if you google for that).
    local ret = {}
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.DataField\nchar="..char)
    for k,_ in spairs(ch.DataStr) do
        ret[#ret+1]=k
    end
    return ret
  end -- End Method

  function api:PointsFields(char) -- BLD: Returns a string with all stringdata fieldnames separated by ";". It is recommended to use a split function to split it (if you don't have one I'm sure you can find some scripts for that if you google for that).
    local ret = {}
    local ch = grabchar(char)
    assert( ch ,"Character doesn't exist\nRPGChar.DataField\nchar="..char)
    for k,_ in spairs(ch.Points) do
        ret[#ret+1]=k
    end
    return ret
  --[[
  local ret$
  local ch = grabchar(char)
  If Not ch GALE_Error("Character doesn't exist",["F,RPGChar.PointsFields","char,"+char])
  For Local K$=EachIn MapKeys(ch.Points)
    If ret ret:+";"
    ret:+k
    Next
  Return ret
  End Method]] end
  
  function api:ListChars() -- ' BLD: Returns a string with all character codenames of characters currently stored in the memory. (They do not need to be in the party right now). The names are separated by ;
  local ret={}
  for k,_ in spairs(RPGChars) do    
    ret[#ret+1]=k
  end--  Next
  end-- End Method  
    
  --End Type  
  
--[[Global RPGChar:RPGLuaAPI = New RPGLuaAPI

GALE_Register RPGChar,"RPGChar" 
GALE_Register RPGChar,"RPGStat"
GALE_Register RPGChar,"RPGStats"
]]


--[[Rem
bbdoc: Loads all RPG data from a JCR directory.
about: The database vars are part of this module, and will only return "True" if succesful"
End Rem
]]
-- $USE Libs/binread
-- $USE Libs/stringmapfile
function RPGLoad(p1,p2,p3) --Function RPGLoad(LoadFrom:TJCRDir,Dir$="")
local function getfile(file,pdat)
  local data
  if not p2 then
   data = love.filesystem.read(p1.."/"..file)
  elseif p1=="love" then
   data = love.filesystem.read(p2.."/"..file)
  elseif p1=='jcr' then
   if not p3 then 
      data = JCR_B(p2.."/"..file)
   else
      data = JCR_B(p2,p3.."/"..file)
   end      
  else
   error("I'm clueless in how you want me to load the RPG data")
  end     
  if pdat then return data else return binread(data,true) end
end  

--Local D$ = Replace(Dir,"\","/"); If D And Right(D,1)<>"/" D:+"/"
local BT --Local BT:TStream
local ak
local P,TN -- F
local LChars--={} --Local LChars:TList = New TList
local ch--:RPGCharacter
local tag
local sv--:rpgstat
local sp--:rpgpoints
print( "Loading party:",p1,p2,p3 )
--' Load party members
BT = getfile("Party") -- JCR_ReadFile(loadfrom,D+"Party")
ak = 0
RPGParty = {}-- New String[ ReadInt(BT) ]
BT:getint() -- Value not needed in Lua, but it had to be read or we'll crash!
while not BT:eof() do -- While Not Eof(BT)
  --If ak>= Len(RPGParty) Print "WARNING! Too many party members in party!"; Exit
  RPGParty[ak+1] = BT:getstring() --TrickyReadString(BT)
  print("Party Member #"..ak.."> "..RPGParty[ak+1])
  if CSay then CSay("Party Member #"..ak.."> "..RPGParty[ak+1]) end
  ak=ak+1
  end -- while
-- CloseFile bt -- BinRead doesn't need it, as it's only a string being tranlated
--ClearMap RPGChars
RPGChars={}
--' Let's first determine which characters we actually have?
--[[
For F=EachIn MapKeys(loadfrom.entries)
  P$ = Upper(D)+"CHARACTER/"
  If Left(F,Len(P))=P And StripDir(F)="NAME" 
    TN = ExtractDir(TJCREntry(MapValueForKey(loadfrom.entries,F)).FileName)
    TN = StripDir(TN)
    ListAddLast LChars,TN
    EndIf
  Next
]]
if not p2 then 
   LChars = love.filesystem.getDirectoryItems( p1.."/Character/" )
elseif p1=='love' then
   LChars = love.filesystem.getDirectoryItems( p2.."/Character/" )
elseif p1=='jcr' then
  if not p3 then
   local FChars = JCR_GetDir( p2.."/Character/",false )
   LChars = {}
   for ch in each(FChars) do
       local chs=mysplit(ch,"/")
       if chs[#chs]=="Name" and chs[#chs-2]=='Character' then LChars[#LChars+1]=chs[#chs-1] end
   end
  else
   local FChars = JCR_GetDir( p2,p3.."/Character/",false )
   LChars = {}
   for ch in each(FChars) do
       local chs=mysplit(ch,"/")
       if chs[#chs]=="Name" and chs[#chs-2]=='Character' then LChars[#LChars+1]=chs[#chs-1] end
   end
  end  
end             
--' Let's now load the characters
for F in each( LChars ) do
  ch=NewRPGCharacter()
  RPGChars[F]=ch -- MapInsert RPGChars,f,ch
  --' Name
  BT = getfile("Character/"..F.."/Name") --""JCR_ReadFile(LoadFrom,D+"Character/"+F+"/Name")
  ch.Name = BT:getstring() -- TrickyReadString(BT)
  --CloseFile BT
  -- Data
  --ch.strdata = ddat(LoadStringMap(LoadFrom,D+"Character/"+F+"/StrData"))
  local tbdata = getfile('Character/'..F..'/StrData')
  local tsdata = readstringmap(tbdata,true)
  for k,v in pairs(tsdata) do api:DefData(ch,k,v) end     
  -- Stats
  BT=getfile("Character/"..F.."/Stats")--bt = JCR_ReadFile(LoadFrom,D+"Character/"+F+"/Stats")
  while not BT:eof() do
    tag = BT:getbyte() --ReadByte(Bt)
    --CSay(tag) -- debug line
    --Select tag
    if tag==1 then --  Case 1
        TN = BT:getstring() --TrickyReadString(BT)
        sv = NewRPGStat()
        ch.Stats[TN]=sv
    elseif tag==2 then --  Case 2
        sv.pure = BT:read()==1 -- ReadByte(BT)
    elseif tag==3 then --  Case 3
        sv.ScriptFile = BT:getstring() --TrickyReadString(BT)
        sv.CallFunction = BT:getstring() --TrickyReadString(BT)    
    elseif tag==4 then --  Case 4
        sv.Value = BT:getint()-- ReadInt(BT)
    elseif tag==5 then -- Case 5
        sv.Modifier = BT:getint() -- ReadInt(BT)
    else --  Default
        --EndGraphics
        error("FATAL ERROR:Unknown tag in character ("..F..") stat file ("..tag..") within this savegame file ")
        --End 
    end--  End Select
  end --  Wend  
  --==CloseFile bt
  --' Lists
  BT = getfile('Character/'..F..'/Lists') -- JCR_ReadFile(LoadFrom,D+"Character/"+F+"/Lists")
  while not BT:eof() do
    tag = BT:getbyte() -- ReadByte(BT)
    --Select tag
    if tag==1 then --  Case 1  
        TN = BT:getstring() -- TrickyReadString(BT)
        ch.Lists[TN]={} --MapInsert ch.lists,TN,New TList
    elseif tag==2 then --  Case 2
        local l=ch.List(TN); l[#l+1]=BT:getstring() --ListAddLast ch.list(TN),TrickyReadString(BT)
    else
        --EndGraphics
        error( "FATAL ERROR:~n~nUnknown tag in character ("..F..") list file ("..tag..") within this savegame file ")
        --End     
   end --   End Select
  end --  Wend
  --CloseFile bt  
  -- Points
  BT = getfile("Character/"..F.."/Points") -- bt = JCR_ReadFile(LoadFrom,D+"Character/"+F+"/Points")
  while not BT:eof() do
    tag = BT:getbyte() -- ReadByte(BT)
    --Select tag
    if tag==1 then --  Case 1
        sp = NewRPGPoints()
        TN = BT:getstring() -- TrickyReadString(BT)
        ch.Points[TN]=sp --MapInsert ch.Points,tn,sp
    elseif tag==2 then --   Case 2
        sp.MaxCopy = BT:getstring() -- TrickyReadString(BT)
    elseif tag==3 then --  Case 3  
        sp.Have = BT:getint() -- ReadInt(BT)
    elseif tag==4 then --  Case 4
        sp.Maximum = BT:getint() -- ReadInt(Bt)
    elseif tag==5 then --  Case 5
        sp.Minimum = BT:getint() -- ReadInt(bt) 
    else --  Default
        --EndGraphics
        error( "FATAL ERROR:~n~nUnknown tag in character ("..F..") points file ("..tag..") within this savegame file ")
        --End
    end--  End Select
  end --  Wend
  --CloseFile bt
  --[[
  ' Portrait
  If JCR_Exists(loadfrom,D+"Character/"+F+"/Portrait.png")  
    ch.portraitbank = JCR_B(LoadFrom,D+"Character/"+F+"/Portrait.png")  
    ch.portrait = LoadImage(ch.portraitbank)  
    If Not ch.portrait And MustHavePortrait
      EndGraphics
      Notify "FATAL ERROR:~n~nPortrait not well retrieved"
      End
      EndIf
    EndIf
  ]]  
end --  Next  
local linktype,linkch1,linkch2,linkstat 
if true then -- If JCR_Exists(LoadFrom,D+"Links") -- Was easier this way :P 
  BT = getfile("Links") -- JCR_ReadFile(Loadfrom,D+"Links")
  repeat
  tag = BT:getbyte()-- ReadByte(bt)
  --Select tag
  if tag==1 then --  Case 001
      linktype = BT:getstring():upper()
      linkch1  = BT:getstring()
      linkch2  = BT:getstring()
      linkstat = BT:getstring()
      --Select Upper(linktype)
        if     linktype== "STAT" then api:LinkStat(linkch1,linkch2,linkstat)    
        elseif linktype== "PNTS" then api:LinkPoints(linkch1,linkch2,linkstat)  
        elseif linktype== "DATA" then api:LinkData(linkch1,linkch2,linkstat)    
        elseif linktype== "LIST" then api:LinkList(linkch1,linkch2,linkstat)    
        else print("ERROR! I don't know what a "..linktype.." is so I cannot link!") end
        --End Select    
  elseif tag==255 then --  Case 255
      break --Exit
  else --  Default
      print ( "ERROR! Unknown link command tag ("..tag..")")
      break --Exit
  end--  End Select  
  until BT:eof()
  --CloseFile bt
end --  EndIf
return true 
end --End Function

--[[
Function RPGStr$() ' Undocumented.  
Local ret$
Local ch:RPGCharacter
For Local P$=EachIn RPGParty
  ret$ :+ "~nParty:"+P
  Next
For Local key$=EachIn MapKeys(RPGChars)
  ch = RPGCharacter(MapValueForKey(RPGChars,key))
  If Not ch 
    Print "WARNING! A wrong record in the chars map"
    Else
    ' Name
    ret:+"~nNEW"
    ret:+"~n~t"+ch.Name
    ' Data
    For Local k$=EachIn MapKeys(ch.strData) ret:+"~n~tD("+K+")="+dstr(ch.strData).value(K) Next
    ' Stats
    For Local skey$=EachIn MapKeys(ch.Stats)
      Local v:rpgstat = ch.stat(skey)
      ret:+"~n~tSt"
      ret:+"~n~t~tskey="+skey
      ret:+"~n~t~tpure="+v.pure
      ret:+"~n~t~tScript="+v.scriptfile
      ret:+"~n~t~tFunction="+v.callfunction
      ret:+"~n~t~tValue="+v.Value
      ret:+"~n~t~tModifier="+v.modifier
      Next
    ' Lists
    ret:+"~n~tLists"
    For Local lkey$=EachIn MapKeys(ch.lists)
      ret:+"~t~t"+lkey
      For Local item$=EachIn ch.list(lkey)
        ret:+"~t~t~t"+item
        Next
      Next
    ' Points
    ret:+"~n~tPoints"
    For Local pkey$=EachIn MapKeys(ch.points)
      ret:+"~n~t~tkey"+pkey
      ret:+"~n~t~tmaxcopy"+ch.point(pkey).maxcopy
      ret:+"~n~t~thave"+ch.point(pkey).have
      ret:+"~n~t~tmax"+ch.point(pkey).maximum
      Next
    EndIf
  Next
Return ret  
End Function
]]
-- $USE Libs/binwrite

local --Private
function SaveRPGLink(BTE,ltype,ch1,ch2,stat) --BTE:TJCRCreateStream,ltype$,ch1$,ch2$,stat$)
  BTE:writebyte(1)--WriteByte BTE.stream,1 ' marks new entry version 1
  BTE:writestring(ltype)
  BTE:writestring(ch1)
  BTE:writestring(ch2)
  BTE:writestring(stat)
end --End Function
--Public

--[[Rem 
bbdoc: Saves the currently available RPG characters and party data
End Rem]]
function RPGSave(D,real) -- Function RPGSave(SaveTo:Object,Dir$="")
--Local BT:TJCRCreate
--Local D$ = Replace(Dir,"\","/")
--Local BTE:TJCRCreateStream
--[[If TJCRCreate(SaveTo)
  BT = TJCRCreate(Saveto)
ElseIf String(SaveTo)
  BT = JCR_Create(String(SaveTo))
Else
  GALE_Error "Unknown object to save RPG stats to"
  EndIf
If D And Right(D,1)<>"/" D:+"/"
]]
-- Save Party members
 -- Dir creation
assert(love.filesystem.createDirectory(D),"Creation of "..D.." failed")
local BTE = binwrite(D.."/Party") -- BT.CreateEntry(D+"Party","zlib")
BTE:putint(#RPGParty) --WriteInt BTE.Stream,Len(RPGParty)
for P in each(RPGParty) do --For Local P$=EachIn RPGParty
  BTE:putstring(P) -- TrickyWriteString BTE.Stream,P
end--  Next
BTE:close()
--' Save all characters
local ch --:RPGCharacter
for key,ch in spairs(RPGChars) do
  --ch = RPGCharacter(MapValueForKey(RPGChars,key))
  if not ch then 
    print( "WARNING! A wrong record in the chars map" )
  else
    assert(love.filesystem.createDirectory(D.."/Character"),"Creation of "..D.."/Character failed")
    assert(love.filesystem.createDirectory(D.."/Character/"..key),"Creation of "..D.."/Character/"..key.." failed")
    -- Name
    BTE = binwrite(D.."/Character/"..key.."/Name") -- BT.CreateEntry(D+"Character/"+key+"/Name","zlib")
    BTE:writestring(ch.Name) -- TrickyWriteString BTE.Stream, ch.Name
    BTE:close()
    --' Data
    writestringmap(dstr(ch.StrData),D.."/Character/"..key.."/StrData") -- SaveStringMap(BT,D+"Character/"+key+"/StrData",dstr(ch.strdata),"zlib")
    -- Stats
    BTE = binwrite(D.."/Character/"..key.."/Stats") -- BT.CreateEntry(D+"Character/"+key+"/Stats","zlib")
    for skey,v in spairs(ch.Stats) do
      --Local v:rpgstat = ch.stat(skey)
      --CSay(serialize('stat.'..skey,v)) -- debug line
      BTE:putbyte(1) --WriteByte bte.stream,1
      BTE:putstring(skey) -- TrickyWriteString bte.stream,skey
      BTE:putbyte(2) -- WriteByte bte.stream,2
      BTE:putbool(v.pure) -- WriteByte bte.stream,v.pure
      BTE:putbyte(3) -- WriteByte bte.stream,3
      BTE:putstring(v.ScriptFile) -- TrickyWriteString bte.stream,v.scriptfile
      BTE:putstring(v.CallFunction) -- TrickyWriteString bte.stream,v.callfunction
      BTE:putbyte(4) -- WriteByte bte.stream,4
      BTE:putint(v.Value) -- WriteInt bte.stream,v.Value
      BTE:putbyte(5) -- WriteByte bte.stream,5
      BTE:putint(v.Modifier) -- WriteInt bte.stream,v.modifier
    end--  Next
    BTE:close()
    --' Lists
    BTE=binwrite(D.."/Character/"..key.."/Lists") -- BTE = BT.CreateEntry(D+"Character/"+key+"/Lists","zlib")
    for  lkey,wlist in spairs(ch.Lists) do -- $=EachIn MapKeys(ch.lists)
      BTE:putbyte(1) -- WriteByte bte.stream,1
      BTE:putstring(lkey) --TrickyWriteString bte.stream,lkey
      for item in wlist do-- =EachIn ch.list(lkey)
        BTE:putbyte(2) -- WriteByte bte.stream,2
        BTE:putstring(item) -- TrickyWriteString bte.stream,item
      end--  Next
    end--  Next
    BTE:close() 
    -- ' Points
    BTE=binwrite(D.."/Character/"..key.."/Points") -- = BT.CreateEntry(D+"Character/"+key+"/Points","zlib")
    for pkey,pp in spairs(ch.Points) do -- =EachIn MapKeys(ch.points)
      BTE:putbyte(1) -- WriteByte bte.stream,1
      BTE:putstring(pkey) -- TrickyWriteString bte.Stream,pkey
      BTE:putbyte(2) -- WriteByte bte.stream,2
      BTE:putstring(pp.MaxCopy) -- TrickyWriteString bte.Stream,ch.point(pkey).maxcopy
      BTE:putbyte(3) -- WriteByte bte.stream,3
      BTE:putint(pp.Have) -- WriteInt bte.stream,ch.point(pkey).have
      BTE:putbyte(4) -- WriteByte bte.stream,4
      BTE:putint(pp.Maximum) -- WriteInt bte.stream,ch.point(pkey).maximum
      BTE:putbyte(5) -- WriteByte bte.stream,5
      BTE:putint(pp.Minimum) -- WriteInt bte.stream,ch.point(pkey).minimum
    end --  Next
    BTE:close() 
    --' Picture
    --[[
    If ch.portraitbank
      bt.addentry ch.portraitbank,D+"Character/"+key+"/Portrait.png","zlib"
      EndIf
    EndIf
  Next
  ]]
  end end -- if ch -- end for key,ch
--' If there are any links list them in the save file
BTE = binwrite(D.."/Links") -- BTE = BT.CreateEntry(D+"Links","zlib")
for ch1,och1 in spairs(RPGChars) do for ch2,och2 in spairs(RPGChars) do  
--local ch1,ch2,stat,och1,och2 -- Local ch1$,ch2$,stat$,och1:RPGCharacter,och2:RPGCharacter
--For ch1=EachIn MapKeys(RPGChars) For ch2=EachIn MapKeys(RPGChars)
  if ch1~=ch2 then
    --och1=RPGCharacter(MapValueForKey(RPGChars,ch1))
    --och2=RPGCharacter(MapValueForKey(RPGChars,ch2))
    for stat,_ in spairs(och1.Stats) do -- =EachIn MapKeys(och1.stats)
      if och1:Stat(stat)==och2:Stat(stat) then SaveRPGLink( BTE,"Stat",ch1,ch2,stat) end
    end--  Next
    for stat,_ in spairs(och1.strdata) do
      --If MapValueForKey(och1.strdata,stat)=MapValueForKey(och2.strdata,stat) SaveRPGLink BTE,"Data",ch1,ch2,stat
      if och1.StrData[stat]==och2.StrData[stat] then  SaveRPGLink( BTE,"Data",ch1,ch2,stat) end
    end--  Next
    for stat,_ in spairs(och1.Points) do -- =EachIn MapKeys(och1.points)
      --If MapValueForKey(och1.points,stat)=MapValueForKey(och2.points,stat) SaveRPGLink BTE,"PNTS",ch1,ch2,stat
      if och1.Points[stat]==och2.Points[stat] then SaveRPGLink ( BTE,"PNTS",ch1,ch2,stat) end
    end --  Next
    for stat,_ in spairs(och1.Lists) do -- =EachIn MapKeys(och1.lists)
      if och1.lists[stat]==och2.Lists[stat] then  SaveRPGLink( BTE,"LIST",ch1,ch2,stat ) end
      --Next
    end --EndIf
  end   
  end end -- Next Next
BTE:putbyte(255) -- WriteByte bte.stream,255
BTE:close()
--' Close if needed
-- If String(SaveTo) BT.Close()  
end -- End Function

-- ]] -- error seeking trick :P

return api
