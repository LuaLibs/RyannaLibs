--[[
***********************************************************
glob.lua
This particular file has been released in the public domain
and is therefore free of any restriction. You are allowed
to credit me as the original author, but this is not 
required.
This file was setup/modified in: 
2018
If the law of your country does not support the concept
of a product being released in the public domain, while
the original author is still alive, or if his death was
not longer than 70 years ago, you can deem this file
"(c) Jeroen Broks - licensed under the CC0 License",
with basically comes down to the same lack of
restriction the public domain offers. (YAY!)
*********************************************************** 
Version 18.05.20
]]
local function glob(pattern) -- Only local to prevent conflicts between the var in which this is returned and function itself.
    local success,data = JCRXCall({'glob',pattern})
    assert(success,data)
    return mysplit(data,"\n")
end

function cdglob(pdir,pattern)
    local dir = replace(pdir,"\\","/")
    
    -- $IF $WINDOWS
       if (not dir) or dir=="" then dir="C:/" end
    -- $FI
    
    -- $IF !$WINDOWS
       if (not dir) or dir=="" then dir="/" end
    -- $FI
    
    if not suffixed(dir,"/") then dir=dir.."/" end
    if dir=="~/" then dir = os.getenv("HOME").."/" end
    print("cd.glob: "..dir..pattern)    
    local data=glob(dir..pattern)
    for i=1,#data do
        data[i]=right(data[i],#data[i]-#dir)
    end
    return data
end
    
return glob
