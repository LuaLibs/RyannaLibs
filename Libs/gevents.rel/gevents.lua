--[[
  gevents.lua
  
  version: 18.01.05
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

local function ge_next(self)
    assert ( self.event or 'Set an event id first before calling an event! ')
    local ev = self.events[self.event]
    ev.cur = ev.cur + 1
    if not self.code then return nil end 
    self.chunk = load(self.jumpscript..self.code,'Event: '..self.name..':'..self.event..'; Chunk: '..self.cur)
    assert(self.chunk,'Compile error in event "'..self.name..':'..self.event..'"; chunk #'..self.cur) 
    return self.chunk
end    

local _running
local function ge_donext(self)
    local chunk = self:next()
    _running = self
    if not chunk then return false end
    chunk()
    _running = nil
    return true
end    

function ge_jump(n) -- Never call this directly. this function is only a global because it could otherwise act strangely.
     assert(_running,'Illegal function call')
     local ev = _running.events[_running.event]
     ev.cur=n
end     

local function ge_start(self,event)
    self.event=event
    local ev = events[event]
    assert(ev,'Event '..event..' does not exist!')
    ret.jumpcode = serialize('local _ge_labels_',ev.labels).."\nfunction jump(l) assert(_ge_labels_[l],'Label '..l does not exist') ge_jump(_ge_labels_[l]) end \n"
end

local function new_event_class(data,name)
   local ret = {}
   ret.name = name
   ret.events = {}
   ret.event = nil
   ret.next = ge_next
   ret.donext = ge_donext
   local collect
   local event
   local colscr
   local ev
   for ln,il in ipairs(data) do
       local l = trim(il)
       if l=="" then
          -- Do nothing, ignore empty lines!
       elseif prefixed(l,"-- event: ") and suffixed(l,' --') then
                   -- 1234567890
          event = left(l,#l-3)
          event = right(event,#event-10)
          event = trim(event)
          ret.events[event] = {code = {}, labels = {}, cur = 0 }
          ev = ret.events[event]
       elseif event then
          if l=="-- begin --" then
             assert(not collect,'Double -- begin -- in event '..name..'; line #'..ln)
             collect=true
             colscr=''
          elseif l=='-- end --' then
              assert(collect,'-- end -- without begin in event '..name..'; line #'..ln)
              ev.code[#ev.code+1]=colscr
          elseif prefixed(l,'-- :') and suffixed(l,': --') then
               local tlab = right(l,#l-4)
               tlab=left(tlab,#l-4)
               tlab=trim(tlab)
               assert(not ev.labels[tlab],'Duplicate label: '..tlab)
               ev.labels[tlab]=#ev.code
          elseif collect then
              colscr = colscr .. l .. '\n'
          else
              ev.code[#ev.code+1] = l
          end    
       end          
   end
   return ret
end

function load_events(file)
     local d = JCR_Lines(file)
     return new_event_class(d,file)
end     
