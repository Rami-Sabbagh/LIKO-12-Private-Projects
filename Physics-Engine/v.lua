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
  self.bounce = testBit(self.spriteFlags,3) and 0.9

  if self.customFilter then
    self.c_down = testBit(self.spriteFlags,4)
    self.c_right = testBit(self.spriteFlags,5)
    self.c_up = testBit(self.spriteFlags,6)
    self.c_left = testBit(self.spriteFlags,7)
  end
end

--=rGonna check my old code for the args
--=h Okay
--=r It should return false for no collision, 
--=r or left/right/up/down for collision and the side that it did collide with
--=h left/right/.. is the for side collided with or ?
function tileObject:collide(other) -- The arguments needed..
  if other.type ~= "Dynamic" then return false end
  
  local allSides = not self.customFilter
  
  --My old code, from the bump demo, you can check the bump demo in LIKO-12
  --=h Is checkbit the same as testBi t heYreE?
  if allSides or self.c_left then --Left
    if other.x + other.w <= self.x then
      if self.bounce then
        other:impactForce(other.velocity * other.mass * -self.bounce)
      else
        other:applyForce(other.velocity:projectOn(xAxis)) --Respond force
      end -- shouldn't this be -1 * 
      return "left"
    end
  end
  if allSides or self.c_up then --Up
    if other.y + other.h <= self.y then
      if self.bounce then -- how much is self.bounce?
        other:impactForce(other.velocity * other.mass * -self.bounce)
      else
        other:applyForce(-1 * other.velocity:projectOn(yAxis)) --Respond force
      end
      return "up"
    end
  end
  if allSides or self.c_right then --Right
    if other.x >= self.x + self.w then
      if self.bounce then
        other:impactForce(other.velocity * other.mass * -self.bounce)
      else
        other:applyForce(-1 * other.velocity:projectOn(xAxis)) --Respond force
      end
      return "right"
    end
  end
  if allSides or self.c_down then --Down
    if other.y >= self.y + self.h then
      if self.bounce then
        other:impactForce(other.velocity * other.mass * -self.bounce)
      else
        other:applyForce(other.velocity:projectOn(yAxis)) --Respond force
      end
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
end

function dynamicObject:impactForce(f)    
  self.velocity = self.velocity + f/self.mass
end

function dynamicObject:applyForce(f) 
  self.sigma_forces = self.sigma_forces + f;
end

function dynamicObject:move(x,y)
  self.x, self.y = world:move(self, x, y, self.filter)
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

function dynamicObject:filter(other) --=h Does dynamicoObj
  if other.collide then
    local side = other:collide(self)

    if side then
      return other.bounce and "bounce" or "slide"
    else
      return false
    end
  else
    return "slide"
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
  dynamicObject.initialize(self,x,y,w,h,97)
end

function playerObject:draw()
  dynamicObject.draw(self)
  if debug then
    local t = tostring(self.velocity)
    printOutlined(t,5,5)
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

    if DynamicSprites[c] then --=h What's left? I missed on somethings, the table tells if this sprite flags are set to tell it's a dynamic object.
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