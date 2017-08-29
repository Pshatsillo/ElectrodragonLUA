sv = net.createServer(net.TCP)
--buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";
local upload = "";
local file_ready, start_file, end_file = false;
local fullreq = ""
local filename = ""
local files = file.list();
local conf_pass = "";
local configLua = "";

if files["mainconfig.lua"] then dofile("mainconfig.lua") end
 
if sv then      
  sv:listen(80, function(conn)
    conn:on ("receive",
        function (conn, req)  
       -- print("upload " .. upload)       
            --print("----request ----- \n\r" .. req .. "----end request --- \n\r")  
            local _, _, method, path, vars = string.find(req, "([A-Z]+) (.+)?(.+) HTTP");
            if(method == nil) then
                _, _, method, path = string.find(req, "([A-Z]+) (.+) HTTP");
            end

            local _GET = {}
            if (vars ~= nil) then
               for k, v in string.gmatch(vars, "(%w+)=([%w.:%w.]+)&*") do
                    print(k.." : " .. v)
                    _GET[k] = v
               end
            end

            if upload then
                if start_file then
                    local file_endr = string.find (req, "------WebKit")
                    if file_endr then 
                        print(req)
                        --print("\r\n -----end of file found! \r\n" .. file_endr .. "\n\r")
                        fullfile = string.sub(req, 0, file_endr - 1)
                        file.open(filename, "a+")
                        file.write(fullfile) 
                        file.close()
                        end_file = true
                        upload = ""
                        start_file = false
                    else
                        fullfile = req
                        file.open(filename, "a+")
                        file.write(fullfile)
                    end
                else
                    local file_start = string.find(req, "stream")
                    for file in string.gmatch(req, "filename=\"([%w%p.]+)\"") do
                        filename = file
                    end
                    if file_start then 
                        start_file = true
                        file_begin = string.sub(req, file_start + 10)
                        local file_endr = string.find (file_begin, "------WebKit")
                        if file_endr then  
                            --print("\r\n -----end of file found! \r\n" .. file_endr .. "\n\r")
                            fullfile = string.sub(file_begin, 0, file_endr - 1)
                            file.open(filename, "a+")
                            file.write(fullfile)
                            end_file = true
                            upload = ""
                            start_file = false 
                            file.close()                               
                        else
                            fullfile = file_begin
                            file.open(filename, "a+")
                            file.write(fullfile)
                        end
                    end  
                end      
            end

            if(path == "/conf") then
                if files["mainconfig.lua"] then
                    local buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";       
                    buf = buf .. "<h2>Configured</h2>";
                    conn:send(buf, function(endrequest) endrequest:close() end);
                else
                    if(_GET.pass ~= nil) then
                        conf_pass = conf_pass.._GET.pass;
                    end            
                    configLua = configLua.."password = \"" .. conf_pass .. "\"\n\r";
                    file.remove("mainconfig.lua")
                    file.open("mainconfig.lua", "w+")
                    file.write(configLua)
                    file.close()
                    local buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";       
                    buf = buf .. "<h2>Configured</h2>";
                    conn:send(buf, function(endrequest) endrequest:close() end);
                    node.restart()
                end

            elseif(path == "/update") then
                buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";                            
                buf = buf.." <form enctype=\"multipart/form-data\" method=\"POST\" action=\"upload\">";
                buf = buf.." <p><b>update:</b><br> ";
                buf = buf.." <input name=\"f\"type=\"file\" size=\"40\" value =\"sec\">";
                buf = buf.." <p><input type=\"submit\"></p> ";
                buf = buf.." </form>";  
            
            elseif(path == "/upload") then
                for v in string.gmatch(req, "boundary=([%w%p.]+)") do 
                    upload = v;
                end
                buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";
                buf = buf.." <p><b>restart</b><br> ";   
                    local tmr1 = tmr.create()
                    tmr1:alarm(500, tmr.ALARM_AUTO, function() 
                    --print(end_file)                    
                        if end_file then
                            conn:send(buf, function(endrequest)
                                endrequest:close() 
                                end_file = false
                                filename = ""
                                node.restart()
                            end)
                         tmr1:stop()         
                        end
                    end)                     

            elseif(path == "/favicon.ico") then
                buf = " ";       
            elseif path then
                if files["mainconfig.lua"] then
                    if string.match(path, password) then
                        local buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";
                        if(_GET.cmd == "0:1")then
                            relay_turnON(0)
                            buf = relay_status[0]
                        elseif(_GET.cmd == "0:0")then
                            relay_turnOFF(0)
                             buf = relay_status[0]
                        elseif(_GET.cmd == "1:1")then
                            relay_turnON(1)
                             buf = relay_status[1]
                        elseif(_GET.cmd == "1:0")then
                            relay_turnOFF(1)
                             buf = relay_status[1]
                        elseif(_GET.cmd == "0:2")then
                            relay_switch(0)
                             buf = relay_status[0]
                        elseif(_GET.cmd == "1:2")then
                            relay_switch(1)
                             buf = relay_status[1]
                        elseif(_GET.cf == "1")then
                            buf = buf .. "<a href=\"javascript:history.back()\">Back</a><br>"
                            buf = buf .. "<form name=\"cf\" method=\"GET\" action=\"/"..password.."\">"
                            buf = buf .. "IP<input name=\"ip\"type=\"text\" size=\"20\" value =\"\"><br>"
                            buf = buf .. "Pwd<input name=\"pass\" type=\"text\" size=\"20\" value =\"sec\"><br>";
                            buf = buf .. "<input type=\"hidden\" name=\"cf\" value=\"2\">"
                            buf = buf .. "<input type=\"submit\" value=\"Save\">"
                            buf = buf .. "</form>"
                        elseif(_GET.cmd == "all")then
                            buf = relay_status[0] .. ";"
                            buf = buf..relay_status[1] .. ";"
                            for i=0,7 do 
                                buf = buf..i2c_status[i] .. ";";
                            end
                        elseif((_GET.cmd == "get") and (_GET.pt)) then
                            if(tonumber(_GET.pt) <= 1) then 
                                buf = relay_status[tonumber(_GET.pt)]
                            else
                                buf = i2c_status[tonumber(_GET.pt) - 2]
                            end
                        elseif(_GET.pt) then
                            if(tonumber(_GET.pt) <= 1) then 
                                buf = buf .. relay_status[tonumber(_GET.pt)] .. "<br>"
                            else
                                buf = buf .. i2c_status[tonumber(_GET.pt) - 2] .. "<br>"
                            end
                            buf = buf.."<p>P ".._GET.pt.." <a href=\"?pt=".._GET.pt.."&cmd=".._GET.pt..":1\">ON</a>&nbsp;<a href=\"?cmd=".._GET.pt..":0\">OFF</a></p>";
                        else  
                            buf = buf .. "Dragon relay (fw:0.1)<br>"
                            buf = buf .. "<a href=\"?cf=1\">Config</a><br>"
                            buf = buf .. "--Ports--<br>"
                            for i=0,9 do 
                               buf = buf.."<a href=\"?pt="..i.."\">P"..i.." - "..ports[i].."</a><br>";
                            end
                        end                   
                --buf = buf.."<p>Relay 1 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
               -- buf = buf.."<p>Relay 2 <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
                        
                        conn:send(buf, function(endrequest) endrequest:close() end);
                    else
                        local buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";
                        buf = buf.."<h1> wrong password</h1>";
                        conn:send(buf, function(endrequest) endrequest:close() end);
                    end
                else
                    local buf = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n";
                    buf = buf.." <form name=\"conf\" method=\"GET\" action=\"\conf\">";
                    buf = buf.." <p><b>password:</b><br> ";
                    buf = buf.." <input name=\"pass\"type=\"text\" size=\"40\" value =\"sec\">";
                    buf = buf.." <p><input type=\"submit\"></p> ";
                    buf = buf.." </form>";
                    conn:send(buf, function(endrequest) endrequest:close() end); 
                end
            end       
        end)
    end)
end
