files = file.list()
if files["config.lua"] then
    print("Config file exists")
    require('config')
else
 cfg={}
 cfg.ssid="ElectroDragon"
 cfg.ip="192.168.4.1"
 cfg.mask="255.255.255.0"
 dhcp_config ={}
 dhcp_config.start = "192.168.4.100"
 wifi.ap.dhcp.config(dhcp_config)
 wifi.ap.config(cfg)
 wifi.setmode(wifi.SOFTAP)
 print("Config file NOT exists")

 print("ESP8266 mode is: " .. wifi.getmode())
 print("The module MAC address is: " .. wifi.ap.getmac())
 print("Config done, IP is "..wifi.ap.getip())


end

--dofile ("i2c.lua")
