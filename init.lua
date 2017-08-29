

function start()

local files = file.list();
if files["start.lua"] then dofile("start.lua") end
--dofile("start.lua")
if files["i2c.lua"] then dofile("i2c.lua") end
--dofile("i2c.lua")
if files["gpio.lua"] then dofile("gpio.lua") end
--dofile("gpio.lua")
if files["tinyweb.lua"] then dofile("tinyweb.lua") end
--dofile("tinyweb.lua")
end

tmr.alarm(  0, 5000,tmr.ALARM_SINGLE, start )