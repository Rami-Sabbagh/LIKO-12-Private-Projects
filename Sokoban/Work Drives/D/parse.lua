--LIKO-12 Sokoban txt parser

local iter = fs.lines("D:/sokoban.txt")
local template = fs.read("D:/template.parser")

for i=1,60 do
  print("Map #"..i) flip()
  iter() --Stars line
  iter() --Maze line
  iter() --File offset
  local width = tonumber(iter():sub(9,-1)) --Size X
  local height = tonumber(iter():sub(9,-1)) --Size Y
  iter() --End
  iter() --Length
  iter() --Empty line
  local mpd, mid = {}, 1
  for y=1,height do
    for tile in string.gmatch(iter(),".") do
      local tid = 0
      if tile == "X" then tid = 5 end
      if tile == "*" then tid = 1 end
      if tile == "@" then tid = 3 end
      if tile == "." then tid = 2 end
      mpd[mid] = tid; mid = mid + 1
    end
  end
  iter() --Empty line
  
  mpd = table.concat(mpd,",")
  local mapstr = template:format(width,height,width,height,mpd)
  if width <=24 and height <= 16 then --Only if they fit.
    fs.write("D:/Sokoban/"..i..".tmx",mapstr)
    fs.append("D:/Sokoban/dims.txt","#"..i.." --> ,, "..width..","..height.."\n")
  end
end