local hex = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}

local value = tonumber(arg[1]) % 256

print(hex[math.floor(value/16)+1] .. hex[value%16+1])
