--Chiptune Generator

local wave, freq, amp = 0, 0, 1
local sel = 0

local waves = 5
local wname = {
 "Sin", "Square", "Pulse","Sawtooth",
 "Triangle", "Noise"
}

local wpics = {}
local wquads = {}
local wx = 0

function _extractPics()
 local pics = {1,5,9,13,17,21}
 for id, sid in ipairs(pics) do
  local rx, ry, rw, rh = SpriteMap:rect(sid)
  rw, rh = 32, 32
   
  local imgd = imagedata(32,32)
  imgd:paste(SpriteMap:data(),0,0, rx,ry,rw,rh)
   
  wpics[id-1] = imgd:image()
  wquads[id-1] = imgd:quad(0,0,64,32)
 end
end

function _init()
 pal(15,0)
 _extractPics()
 Audio.generate(wave, freq, amp)
end

function _drawPic()
 SpriteGroup(241, 136,40, 6,6)
 clip(136+8,40+8, 32,32)
 wpics[wave]:draw(136+8-wx,40+8-(32*amp-32)/2, 0, 1,amp, wquads[wave])
 clip()
end

function _drawUI()
 color(12)
 
 print("CHIPTUNE GENERATOR V2.0", 5,40)
 
 if sel == 0 then
  color(7)
  print("> Wave: "..wname[wave+1],10,55)
 else
  color(6)
  print("Wave: "..wname[wave+1],10,55)
 end
 
 if sel == 1 then
  color(7)
  print("> Frequency: "..freq.."Hz",10,65)
 else
  color(6)
  print("Frequency: "..freq.."Hz",10,65)
 end
 
 if sel == 2 then
  color(7)
  print("> AMP: "..amp,10,75)
 else
  color(6)
  print("AMP: "..amp,10,75)
 end
end

function _draw()
 clear(0)
 
 rect(0,32, 192, 128-64, false, 5)
 
 pushMatrix()
 _drawUI()
 _drawPic()
 popMatrix()
end

function _updatePic(dt)
 wx = (wx + (freq/10)*dt) % 32
end

function _update(dt)
 _updatePic(dt)
 
 if btnp(3) then
  sel = sel-1
  if sel == -1 then
   sel = 2
  end
 elseif btnp(4) then
  sel = (sel+1)%3
 end
 
 if btnp(5) then --Inc
  if sel == 0 then
   wave = math.min(wave+1,waves)
  elseif sel == 1 then
   freq = math.min(freq+100,20000)
  elseif sel == 2 then
   amp = amp+0.1
  end
  
  Audio.generate(wave,freq,amp)
 elseif btnp(6) then --Dec
  if sel == 0 then
   wave = math.max(wave-1,0)
  elseif sel == 1 then
   freq = math.max(freq-100,0)
  elseif sel == 2 then
   amp = amp-0.1
  end
  
  Audio.generate(wave,freq,amp)
 end
 
 if btnp(7) then
  Audio.generate()
 end
end