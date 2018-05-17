local JSON = require("Libraries.JSON")

--Load the font image.
local fimg = imagedata(fs.read("D:/rpi_font.png"))

local font = {}
local fontchars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!?[](){}.,;:<>+=%#^*~/\\|$@&`"\'-_ '
local charsIter = string.gmatch(fontchars,".")

print("Parsing Chars...") flip()

local charx = 1-5
for char in charsIter do
  charx = charx + 5
  --print("Char: "..tostring(char)) flip()
  font[char] = {}
  for x=0,3 do
    font[char][x+1] = {}
    for y=0,4 do
      local pix = fimg:getPixel(charx+x,y)
      font[char][x+1][y+1] = (pix > 0)
    end
  end
end

print("Encoding Chars...") flip()

fs.write("D:/rpi_font.json",JSON:encode_pretty(font))

print("Done !")

return 0