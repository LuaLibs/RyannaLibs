--[[
  as_pathfinder.lua
  
  version: 17.08.15
  Copyright (C) 2017 Jeroen P. Broks
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



--Strict
--'If you solely want to use this module, you may turn the import to the MKL_Version module, and the two lines starting with MKL_ into comments, as the module only uses it for version referrence other modules (or games written by me) can call on.
--Import tricky_units.MKL_Version

--MKL_Version "Tricky's Units - PathFinder.bmx","15.09.02"
--MKL_Lic     "Tricky's Units - PathFinder.bmx","ZLib License"

--require ('AStar') --Include "include/aStarLibrary.bmx"
-- *import bank
-- *import mkl_version
-- j_love_import("$$mydir$$/AStar.lua")

-- $USE libs/bank


--[[
-- *if ignore
local mkl = {}
-- *fi
mkl.version("Love Lua Libraries (LLL) - as_pathfinder.lua","17.08.15")
mkl.lic    ("Love Lua Libraries (LLL) - as_pathfinder.lua","ZLib License")
]]



--[['A Star Walk Engine Vars
Rem
bbdoc: This type should be used with the pathfinder commands
End Rem]]
function newPathFinderUnit() --Type PathFinderUnit 'Extends TBBType

--[[
	'Method New()
	'	Add(unit_list)
	'End Method

	'Method After:bbunit()
	'	Local t:TLink
	'	t=_link.NextLink()
	'	If t Return bbunit(t.Value())
	'End Method

	'Method Before:bbunit()
	'	Local t:TLink
	'	t=_link.PrevLink()
	'	If t Return bbunit(t.Value())
	'End Method
]]
  local ret = {	

	ID=0, xLoc=0.0, yLoc=0.0, speed=0.0, sprite=0,
	pathAI=0, pathStatus=0, pathLength=0,  pathLocation=0, pathBank=CreateBank(0)--[[:TBank = New TBank]], xPath=0, yPath=0,
	targetX=0, targetY=0, target=nil --[[:PathFinderUnit]],
	
	Success = false}
	
	return ret
end -- function --End Type


--[[Rem
bbdoc: BEFORE using ANY routine within this module at all this function variable must be set which tells PathFinder which areas are blocked and which are not. If you have multiple routines defining that it simply means you gotta redefine this variable. Simply create a function using X,Y for variables and define it to this var (without the () and parameters).
about: Pathfinder is used by the Kthura map system and sets this function automatically whenever an actor is required to walk. So if you use the Kthura system in your games, you should keep that in mind, if you are not a Kthura user, then don't bother and set this variable with your own blocking routines.
End Rem ]]
--[[Global]] PF_Block=function(X,Y) end -- 2d function! (X,Y)
--Rem -- Kept for backwards setback possibilities if they would be required.
--[[Private
PF = nil --Global PF:TPathFinder
function walkability(X,Y)
	return PF:Block(X,Y)
end--	End Function
--Public
--End Rem ]]


--[[
Rem
bbdoc: Find the way.
End Rem ]]
function FindTheWay(StartX,StartY,TargetX,TargetY,Speed) --:PathFinderUnit(StartX#,StartY#,TargetX,TargetY,Speed=1)
local Ret = newPathFinderUnit()
Ret.xLoc = StartX
Ret.yLoc = StartY
Ret.speed = Speed or 1
if FindPath(Ret,TargetX,TargetY)~=1 then 
	--DebugLog "Warning! Finding the path has failed"
	Ret.Success=false
	return Ret
	end -- EndIf
Ret.Success=true
return Ret
end -- End Function

--[[Rem
bbdoc: Will put in the next coordinates into the the X# and Y# coordinates
End Rem]]
function ReadWay(PFU,X,Y) -- (PFU:PathFinderUnit,X Var,Y Var) -- Remember the VAR.... X and Y must be returned too...
CheckPathStepAdvance(PFU)
return PFU.xPath,
       PFU.yPath 
end --End Function

--Rem
--bbdoc: How long is the path?
--End Rem
function LengthWay(PFU) --(:PathFinderUnit)
   return PFU.PathLength
end --End Function

--
--Rem
--bbdoc: Will adjust X and Y in accordance of the current path position. When a path location is given that is wrong these values won't be altered
--End Rem
function ReadWaySpot(PFU,Spot,X,Y) -- (PFU:PathFinderUnit,Spot,X Var,Y Var)
if Spot>PFU.pathLength then return X,Y end
if Spot<0 then return X,Y end
return ReadPathX(PFU,Spot),
       ReadPathY(PFU,Spot)
end       
--End Function

return true