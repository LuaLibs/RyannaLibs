--[[
  gini is not ini.lua
  
  version: 18.01.03
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

-----

--[[

    This is a Lua Conversion of code originally written in BlitzMax
    
]]    
-- Strict
--Import tricky_units.StringMap
--Import tricky_units.advdatetime
--Import tricky_units.Listfile

-- old *import stringmap
-- old *import listfile
-- old *import filestuff


--mkl.version("Love Lua Libraries (LLL) - gini.lua","17.08.18")
--mkl.lic    ("Love Lua Libraries (LLL) - gini.lua","ZLib License")

-- $USE libs/stringmap
-- $USE libs/Listfile 

--Private
--Type tf
--  Field f(Ini:TIni,para$)
--  End Type

  
local tfm = {} -- :TMap = New TMap  

local function IniCall(name,ini,para)
local f = tf(MapValueForKey(tfm,name:upper()))
if not f then return print("ERROR! Call: I could not retrieve function: "+name) end
f(ini,para)
end -- End Function

--Public

--[[
Rem
bbdoc: Registers a function to initfile
about: These functions can be called when loading an ini file. I must note this is a read-only function, as the effect of it will be deleted when you write these functions. Just register a function with the ini and a single string as parameter. The Function can then do with the ini according to what the ini file wants. (This function works case INSENSITIVELY)
]] -- End Rem]]
local IniFuncs={
     EachVar = function(self) return MapKeys(self.Vars) end,
     C = function(self,T) return self.Vars:value(T:upper()) end,
     D = function(self,T,V) MapInsert(self.Vars,T:upper(),V) end,
     Kill = function(self,T) MapRemove(self.Vars,T:upper()) end,
     CList = function(self,T,OnlyIfNew)
               if OnlyIfNew and MapContains(self.Lists,T:upper()) then return end
               MapInsert(self.lists,T:upper(),{})
             end,  
     List = function(self,T)
                  ret =  MapValueForKey(self.Lists,T:upper())
                  if not ret then print("WARNING! List "+T+" not found!") end
                  return ret
            end  ,
     Add = function(self,T,item)
              if not MapContains(self.Lists,T:upper()) then  self.CList(T) end
              local r = self:List(T)
              r[#r+1]=item
           end ,
     DuplicateList=function(self,Ori,Target) MapInsert(self.Lists,Target:upper(),MapValueForKey(self.Lists,Ori:Upper())) end,              
}
function Ini_RegFunc(Name,Func) --Name$,Func(Ini:TIni,Para:String))
local f -- :tf = New tf
f = func
MapInsert( tfm,Name:upper(),f)
end -- End Function

--[[Rem 
bbdoc: Variable used by init reader/writer
]] -- End Rem
function newTIni() -- Type TIni
  local ret
  
  ret.Vars=NewStringMap --:StringMap = New StringMap
  ret.Lists=NewTMap --:TMap = New TMap

  for k,f in Ini_RegFuncs do ret[k]=f end  
  
  return ret 
  
end  --End Type
  
  
local AllowedChars = "qwertyuiopasdfghjklzxcvbnm[]{}1234567890-_+$!@%^&*()_+QWERTYUIOPASDFGHJKL|ZXCVBNM<>?/ '."

function IniString(A,XAllow)
local i
local ret = {[false]="",[true]=A}
local allowed = true
for i=1 , #A do
  local check1,check2 = (allowedchars..(XAllow or "")).find(mid(a,i,1),1,true)
  allowed = allowed and check1 --allowed = allowed And (allowedchars+XAllow).find(Chr(A[i]))>=0
  --'If Not allowed Print "I will not allow: "+Chr(A[i])+"/"+A
  ret[false] = ret[false] .. "#("..string.byte(mid(a,i,1))..")"
  end
return ret[allowed] 
end --End Function

function UnIniString(A)
local ret=A
local i
for i=0 , 255 do
  ret = replace(ret,"#("..i..")",string.char(i))
  end
return ret  
end --End Function

function SaveIni(file,Ini,real)  
local BT --:TStream
local f
local Done = {} --:TList = New TList
local L={} --:TList = New TList
local LN,Dupe
local K --$
local output="[rem]\nGenerated by a program written in Love2D"
--[[
If String(file)
  f = True
  bt = WriteFile(String(file))
ElseIf TStream(file)
  f = False
  bt = TStream(file)  
  EndIf
If Not BT
  Print "ERROR!"
  If String(file) 
    Print "SaveIni: Error writing to "+String(file)
  Else
    Print "SaveIni: Either a file could not be created or an unsupported object type is given to me"
    EndIf
  Return
  EndIf 
]]  
--WriteLine bt,"[rem]~nGenerated by: "+StripDir(AppFile)+" ("+AppTitle+")~n"+PNow()+"~n"

output = output .."[vars]\n"
for K in MapKeys(ini.Vars) do
  output = output .. IniString(K).."="..IniString(Ini.C(K),",.").."\n"
  --WriteLine bt,IniString(K)+"="+IniString(Ini.C(K),",.")
end  --Next
output = output .. "\n\n"
for k in MapKeys(ini.Lists) do --For K$=EachIn(MapKeys(ini.lists))
  LN=IniString(K)
  if not ListContains(L,K) then
    for  K2 in MapKeys(ini.lists) do
      if K~=K2 and (not ListContains(L,K2)) and ini.list(K)==ini.list(K2) then
        LN=LN..","..IniString(K2)
        ListAddLast(L,K2)
        end -- EndIf
      end --Next
    output = output .."[List:"+LN+"]\n"  
    for V in each( ini.list(K) ) do
      output = output .. IniString(V,",.:;\"") .."\n"
      end -- Next
    output = output .."\n\n"  --WriteLine BT,""     
    end -- EndIf 
  end -- Next  
-- If f CloseFile bt
if real then
   bt = io.open(file,"wb")
   bt:write(output)
   bt:close()
else
   love.filesystem.write(file,output)
end      
end --End Function      
      
function LoadIni(File,AIni,nMerge,real)
local Ini = AIni
if nMerge or (not Ini) then Ini=NewTIni end
--Local wtag$,Lst:TList,line$,tag$,tagsplit$[],tagparam$[],tline$,cmd$,para$,pos
local wtag,lst,line,tag,tagsplit,tagparam,tline,cmd,para,pos
tag="OLD"
for line in each ( Listfile(File) ) do
  if line~="" then
    if left(trim(line),1)=="[" and right(trim(line),1)=="]" then 
      wTag = mid(trim(line),2,#(trim(line))-2)
      tagsplit=mysplit(wTag,":")
      tag = tagsplit[1]:upper()
      if upper(tagsplit[1])=="LIST" then
        if #(Tagsplit[1])<2 then return Print("ERROR! Incorrectly defined list!") end
        lst = {}        
        for K in each( tagsplit[2].split(",") ) do
          -- 'ini.clist(UnIniString(K))
          MapInsert(Ini.Lists,upper(UnIniString(K)),lst)
          end --Next
        --'lst=ini.list(UnIniString(K)) 
        end -- EndIf
    else
      --Select tag
        if     tag=="REM" then
        elseif tag=="OLD" then
          print("[OLD] removed! It was deprecated in the first place!")
          --[[ FUCK YOU, this crap is deprecated! So let's ignore it!
          tline = trim(line)
          if left(tline,2)~="--" then 
            tagsplit=mysplit(tline,":")
            if Len(tagsplit)<2 then 
              print("Invalid old definition: "+tline)
            else
              if #(tagsplit)>2 then 
                for i=3 , #(tagsplit) do
                  tagsplit[2]=tagsplit[2]..":"..tagsplit[i]
                  end --Next
                end --EndIf
              --Select tagsplit[0]
                if tagsplit[0]=="Var" then
                  tagparam = tagsplit[1].split("=")
                  If Len(tagparam)<2 
                    Print "Invalid old var definition: "+Tline
                  Else
                    For Local ak=0 Until 256 
                        tagparam[1] = Replace(tagparam[1],"%"+Right(Hex(ak),2),Chr(ak))
                        Next
                    ini.D(tagparam[0],tagparam[1])
                    EndIf
                Case "Add"
                  tagparam = tagsplit[1].split(",")
                  If Len(tagparam)<2 
                    Print "Invalid old var definition: "+Tline
                  Else
                    ini.Add(tagparam[0],Right(tagsplit[1],Len(tagsplit[1])-(Len(tagparam[0])+1)))
                    EndIf
                Case "Dll"    
                  tagparam = tagsplit[1].split(",")
                  If Len(tagparam)<2 
                    Print "Invalid old var definition: "+Tline
                  Else
                    ini.DuplicateList(tagparam[0],tagparam[1])
                    EndIf
                End Select                          
              EndIf
            EndIf
        ]]            
        elseif tag=="SYS" or tag=="SYSTEM" then   
          tline = trim(line)
          pos,_ = tline:find(" ",1,true)
          if pos<-1 then  pos = #(tline) end
          cmd  = upper(left(tline,pos))
          para = mid(tline,pos+1,#tline-pos)
          --Select cmd
          if cmd== "IMPORT" or cmd=="INCLUDE" then
              pos,_ = para.find("/",1,true)<0
              -- *if windows
              pos = pos and mid(para2,1)~=":"
              pos = pos and para.find("\\",1,true)
              -- *fi
              if pos then para=extractdir(file.."/"..para) end
              --[[?debug
              Print "Including: "+para
              ?]]
              LoadIni ( para,ini,false,true )              
            else
            --Default
              print ("System command "..cmd.." not understood: "..tline )
            end --End Select   
        elseif tag=="VARS" then
          if not line:find("=",1,true) then 
            print("Warning! Invalid var definition: "+line)
          else
            tagsplit=mysplit(line,"=")
            Ini.D(UnIniString(tagsplit[1]),UnIniString(tagsplit[2]))
            end -- EndIf
        elseif tag=="LIST" then
          ListAddLast(lst,uninistring(line))
        elseif "CALL" then
          if not line:find(":",1,true) then
            print("Call: Syntax error: "+line)
          else
            tagsplit=mysplit(line,":")
            IniCall(tagsplit[1],ini,UnIniString(tagsplit[2]))
          end--  EndIf
            
        else --Default
          Print( "ERROR! Unknown tag: "..tag)
          return  
        end --End Select  
      end --EndIf
    end --EndIf   
  end--Next
end --End Function

-------------------------------------------------------------------------
-- If LoadIni is too awkward for you to use, you can use this in stead --
-------------------------------------------------------------------------
function ReadIni(file,real)
  ret = {} --Local ret:TIni = New TIni
  LoadIni(file,ret,true,real)
  return ret
end --End Function  
  
return true
