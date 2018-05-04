local sqrt, sin, cos = math.sqrt, math.sin, math.cos
local pi = math.pi
local r1, r2 =  0          ,  1.0
local g1, g2 = -sqrt( 3 )/2, -0.5
local b1, b2 =  sqrt( 3 )/2, -0.5


--[[--
  @param h a real number between 0 and 2*pi
  @param s a real number between 0 and 1
  @param v a real number between 0 and 1
  @return r g b a
]]
local function HSVToRGB( h, s, v, a )
  h=h+pi/2--because the r vector is up
  local r, g, b = 1, 1, 1
  local h1, h2 = cos( h ), sin( h )
  
  --hue
  r = h1*r1 + h2*r2
  g = h1*g1 + h2*g2
  b = h1*b1 + h2*b2
  --saturation
  r = r + (1-r)*s
  g = g + (1-g)*s
  b = b + (1-b)*s
  
  r,g,b = r*v, g*v, b*v
  
  return r*255, g*255, b*255, (a or 1) * 255
end

return HSVToRGB

--[[
   This file has been created by raingloom
   It has been adapted for the Rynna system by Jeroen P. Broks
   The original didn't come with any license text from: https://gist.github.com/raingloom/3cb614b4e02e9ad52c383dcaa326a25a
   An example to use in Love2D is provided on that site
]]    