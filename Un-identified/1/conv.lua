local array = fs.load("D:/defacto.lua")()
local strchar = string.char
for k,v in pairs(array) do
  array[k] = strchar(v)
end

local data = table.concat(array)
fs.write("D:/defacto.bin",data)