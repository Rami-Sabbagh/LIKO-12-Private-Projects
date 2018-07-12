--Physics Engine V1.0

--[[VS CODE Chat


---

References:
vector.lua - http://hump.readthedocs.io/en/latest/vector.html
bump.lua - https://github.com/kikito/bump.lua
middleclass.lua - https://github.com/kikito/middleclass/wiki
LIKO-12 Docs - http://liko-12.readthedocs.io/en/latest/   
Plain Paper - https://docs.google.com/document/d/1lgEObHPm17tnRt3go36A8UZaASOaQ5-VtZD87i7e400/edit?usp=sharing

]]

--Localize bitop library for faster speed and shorter name.
local band, bor, bxor, lshift, rshift = bit.band, bit.bor, bit.bxor, bit.lshift, bit.rshift

local sw, sh = screenSize()

local yAxis = vector(0,1)
local xAxis = vector(1,0)

local world --Bump world
local meter = 8 --1 meter = 8 pixels = 1 tile/cell.

local debug = true

--------------------------------------

--BitID: Bit number [0-7]
local function testBit(byte,bitID)
  bitID = lshift(1,bitID)
  return (band(byte,bitID) > 0)
end

local function printOutlined(t,x,y)
  color(0)
  print(t,x-1,y)
  print(t,x+1,y)
  print(t,x,y-1)
  print(t,x,y+1)
  color(7)
  print(t,x,y)
end

--------------------------------------

local SpriteBatch = SpriteMap:image():batch(TileMap:width() * TileMap:height(),"static")

--------------------------------------

local STypes = {} --STypes[SpriteID] = Tile/Decor/Static/Dynamic.

local TileSprites = {} --TileSprites[SpriteID] = true.
local DecorSprites = {} --DecorSprites[SpriteID] = true.
local StaticSprites = {} --StaticSprites[SpriteID] = true.
local DynamicSprites = {} --DynamicSprites[SpriteID] = true.

--=r Will send you a pic of the flags

for i=1, #SpriteMap.flags do
  local flag = SpriteMap:flag(i)
  local stype = band(flag,3) --First 2 bits.
  
  if stype == 0 then --Tile
    STypes[i] = "Tile"
    TileSprites[i] = true
  elseif stype == 1 then --Decor
    STypes[i] = "Decor"
    DecorSprites[i] = true
  elseif stype == 2 then --Static
    STypes[i] = "Static"
    StaticSprites[i] = true
  elseif stype == 3 then --Dynamic
    STypes[i] = "Dynamic"
    DynamicSprites[i] = true
  end
end

--------------------------------------

local objectBase = class("physics.object.base")

function objectBase:initialize(x,y,w,h,spriteID)
  self.x, self.y, self.w, self.h = x or 0, y or 0, w or 8, h or 8

  self.spriteID = spriteID or 1
  self.spriteFlags = SpriteMap.flags[self.spriteID]

  world:add(self, self.x, self.y, self.w, self.h) --Register this object to the world
end

function objectBase:getRect()
  return {self.x, self.y, self.w, self.h}
end

--------------------------------------

local tileObject = class("physics.tile.base",objectBase)

tileObject.type = "Tile"

function tileObject:initialize(x,y,w,h,spriteID)
  objectBase.initialize(self,x,y,w,h, spriteID)

  self.customFilter = testBit(self.spriteFlags,2)
  self.bounce = testBit(self.spriteFlags,3) and 0.9 or 0

  if self.customFilter then
    self.c_down = testBit(self.spriteFlags,4)
    self.c_right = testBit(self.spriteFlags,5)
    self.c_up = testBit(self.spriteFlags,6)
    self.c_left = testBit(self.spriteFlags,7)
  end
end

function tileObject:filter(other)
  if other.type ~= "Dynamic" then return false end
  
  local collideType = "touch"--self.bounce and "bounce" or "slide"

  if not self.customFilter then return collideType end
  
  if self.c_left then --Left
    if other.x + other.w <= self.x then return collideType end
  end
  if self.c_up then --Up
    if other.y + other.h <= self.y then return collideType end
  end
  if self.c_right then --Right
    if other.x >= self.x + self.w then return collideType end
  end
  if self.c_down then --Down
    if other.y >= self.y + self.h then return collideType end
  end

  return false
end

function tileObject:collide(other,collision)
  if other.type ~= "Dynamic" then return false end
  
  local allSides = not self.customFilter

  if allSides or self.c_left then --Left
    if other.x + other.w <= self.x then
      other:impactForce(other.velocity:projectOn(xAxis) * other.mass * -(1+self.bounce)) --Respond force
      return "left"
    end
  end
  if allSides or self.c_up then --Up
    if other.y + other.h <= self.y then
      other:impactForce(other.velocity:projectOn(yAxis) * other.mass * -(1+self.bounce)) --Respond force
      return "up"
    end
  end
  if allSides or self.c_right then --Right
    if other.x >= self.x + self.w then
      other:impactForce(other.velocity:projectOn(xAxis) * other.mass * -(1+self.bounce)) --Respond force
      return "right"
    end
  end
  if allSides or self.c_down then --Down
    if other.y >= self.y + self.h then
      other:impactForce(other.velocity:projectOn(yAxis) * other.mass * -(1+self.bounce)) --Respond force
      return "down"
    end
  end
  return false
end

--------------------------------------

local staticObject = class("physics.static.base",objectBase)

staticObject.type = "Static"

function staticObject:initialize(x, y, w, h, spriteID)
  objectBase.initialize(self, x, y, w, h, spriteID)

end

--------------------------------------

local dynamicObject = class("physics.dynamic.base")

dynamicObject.type = "Dynamic"

function dynamicObject:initialize(x,y,w,h,spriteID)
  objectBase.initialize(self,x,y,w,h,spriteID)

  self.mass = 1
  self.volume = 1
  self.density = self.mass/self.volume

  self.velocity = vector()
  self.acceleration = vector()
  self.sigma_forces = vector()

  self.collisions = {}
end

function dynamicObject:impactForce(f)    
  self.velocity = self.velocity + f/self.mass
end

function dynamicObject:applyForce(f) 
  self.sigma_forces = self.sigma_forces + f;
end --=r Hello!

function dynamicObject:move(x,y)
  local actualX, actualY, cols, len = world:move(self, x, y, self.filter)
  self.x, self.y = actualX, actualY

  self.collisions = cols

  for k, o in pairs(cols) do
    if o.other.collide then
      o.other:collide(self,o.item,o)
    end
  end
end

function dynamicObject:updatePhysics(dt)
  --Update the acceleration
  self.acceleration = self.sigma_forces/self.mass
  
  --Clear the forces
  self.sigma_forces = self.sigma_forces*0
  
  --Update the velocity
  self.velocity = self.velocity + self.acceleration*dt
  
  --Update the body position
  local deltaVector = self.velocity*(dt*meter)
  local deltaX, deltaY = deltaVector:unpack()
  self:move(self.x + deltaX, self.y + deltaY)
end

function dynamicObject:draw()
  Sprite(self.spriteID, self.x, self.y)
end

function dynamicObject:update(dt)
  self:updatePhysics(dt)
end

function dynamicObject:filter(other)
  if other.filter then
    return other:filter(self)
  else
    return "cross"
  end
end

--------------------------------------

local weight = {
  gravity = vector(0,9.807),
  updateWeight = function(self)
    self.weight = self.weight or self.mass*self.gravity
    self:applyForce(self.weight)
  end
}

--------------------------------------

local dynamicClasses = {}

--------------------------------------

local playerObject = class("physics.dynamic.player", dynamicObject)

dynamicClasses[0] = playerObject

playerObject:include(weight)

function playerObject:initialize(x,y,w,h,spawnerSpriteID)
  dynamicObject.initialize(self,x+1,y+1,w-2,h-1,97)
end

function playerObject:draw()
  Sprite(self.spriteID, self.x-1, self.y-1)
  if debug then
    local t = tostring(self.velocity)
    printOutlined(t,5,5)
    printOutlined("- Collisions: "..#self.collisions,5,15)
  end
end

function playerObject:update(dt)
  self:updateWeight()
  self:updatePhysics(dt)
end

--------------------------------------

local function loadTiles()
  TileMap:map(function(x,y,c)
    if TileSprites[c] then
      SpriteBatch:add(SpriteMap:quad(c),x*8,y*8)

      tileObject(x*8, y*8, 8, 8, c)
    end

    if DynamicSprites[c] then
      local flag = SpriteMap.flags[c]
      local classID = rshift(flag,2)

      local objClass = dynamicClasses[classID] or dynamicObject
      objClass(x*8, y*8, 8, 8, c)
    end
  end)
end

local function dynamicObjectsFilter(obj)
  return obj.type == "Dynamic"
end

local function drawDynamicObjects()
  local objects, len = world:queryRect(0,0,sw,sh, dynamicObjectsFilter)
  for i=1, len do
    local obj = objects[i]
    if obj.draw then
      obj:draw()
    end
  end
end

local function updateDynamicObjects(dt)
  local objects, len = world:queryRect(0,0,sw,sh, dynamicObjectsFilter)
  for i=1, len do
    local obj = objects[i]
    if obj.update then
      obj:update(dt)
    end
  end
end

--------------------------------------

function _init()
  world = bump.newWorld(8*4)
  loadTiles()
end

function _draw()
  clear()
  SpriteBatch:draw(0,0)
  drawDynamicObjects()
end

function _update(dt)
  updateDynamicObjects(dt)
end