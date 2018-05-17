local InitMap = TileMap:cut() --Clone the map, Backup it.




local function _processMap()
  local pmap = TileMap:cut()
  
  local function is(x,y)
    local tid = TileMap:cell(x,y)
    if tid and tid == 2 then return true end
    return false
  end
  
  local function isnt(x,y)
    local tid = TileMap:cell(x,y)
    if tid and tid == 2 then return false end
    return true
  end
  
  TileMap:map(function(x,y,tid)
    if tid == 2 then
      if isnt(x-1,y) and isnt(x,y-1) and is(x-1,y-1) then
        pmap:cell(x,y,51)
      elseif isnt(x-1,y) and isnt(x,y-1) then
        pmap:cell(x,y,3)
      elseif isnt(x-1,y) then
        pmap:cell(x,y,27)
      elseif isnt(x,y-1) then
        pmap:cell(x,y,4)
      elseif is(x-1,y) and is(x,y-1) and isnt(x-1,y-1) then
        pmap:cell(x,y,52)
      else
        pmap:cell(x,y,28)
      end
    elseif tid == 1 then
      if is(x-1,y) and is(x,y-1) then
        pmap:cell(x,y,5)
      elseif is(x-1,y) and is(x-1,y-1) then
         pmap:cell(x,y,29)
      elseif is(x-1,y) then
         pmap:cell(x,y,53)
      elseif is(x,y-1) and is(x-1,y-1) then
         pmap:cell(x,y,6)
      elseif is(x,y-1) then
         pmap:cell(x,y,7)
      elseif is(x-1,y-1) then
         pmap:cell(x,y,30)
      end
    end
  end)

  TileMap = pmap
end

function _init()
  clear(0)
  colorPalette(0,10,10,10)
  colorPalette(5,35,35,35)
  _processMap()
end

function _update(dt)
  
end

function _draw()
  TileMap:draw()
end