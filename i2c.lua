oldvalue = -1
i2c_status = {"NA", "NA","NA","NA","NA","NA","NA","NA"}
id = 0
sda = 1
scl = 2

i2c.setup(id, sda, scl, i2c.SLOW)

function read_reg(dev_addr, reg_addr)

    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, reg_addr)
    i2c.stop(id)
    --tmr.delay(100)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    c = i2c.read(id, 1)
    i2c.stop(id)
    return c
end

function scan()
print("scanning...")
    
for i=0,127 do

    if (string.byte(read_reg(i, 0)) == 0) then
    print ("device found" .. string.format("%02X", i)) else
   -- print ("empty..." .. string.format("%02X", i))
    end
end
    --reg = read_reg(0x27, 0x00)
    --print(string.byte(reg))
end

function checkstatus()


    reg = read_reg(0x38, 0xFF)
    
    --print(string.format("%02X", string.byte(reg)))
    --print(bit.set(reg))
    value = string.byte(reg)
    
    if(value ~= oldvalue) then
        for i=0,7 do
            res = bit.isclear(string.byte(reg),i)
            if(res) then
                i2c_status[i] = "ON"
                print ("pin " .. i+1 .. " closed")
            else 
                i2c_status[i] = "OFF"
                print ("pin " .. i+1 .. " opened")
            end
        end
        oldvalue = value
    end
end



tmr.alarm(1, 50, tmr.ALARM_AUTO, checkstatus)
