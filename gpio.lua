relay1_gpio = 6
relay2_gpio = 7

gpio.mode(relay1_gpio, gpio.OUTPUT)
gpio.mode(relay2_gpio, gpio.OUTPUT)

relay_status = {}

function relay_turnON(port)
    if (port == 0) then gpio.write(relay1_gpio, gpio.HIGH); end
    if (port == 1) then gpio.write(relay2_gpio, gpio.HIGH); end
    relay_status[port] = "ON"
end

function relay_turnOFF(port)
    if (port == 0) then gpio.write(relay1_gpio, gpio.LOW); end
    if (port == 1) then gpio.write(relay2_gpio, gpio.LOW); end
    relay_status[port] = "OFF"
end

function relay_scan()
    if (gpio.read(relay1_gpio) == 0) then relay_status[0] = "OFF" else relay_status[0] = "ON" end
    if (gpio.read(relay2_gpio) == 0) then relay_status[1] = "OFF" else relay_status[1] = "ON" end
end

function relay_switch(port)
    if (relay_status[port ] == "OFF") then 
             relay_turnON(port)
    elseif (relay_status[port] == "ON") then
             relay_turnOFF(port)
    end    
end

relay_scan()
