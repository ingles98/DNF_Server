--local _s = require'sConn'
--local db = sqlite3.open("dnf.db")
require('dbHandler')

local S = {}

local socket = require( "socket" )

local clientList = {}
local clientBuffer = {}

local deltaTime = love.timer.getTime()*1000
local startTime = deltaTime

S.getIP = function()
    local s = socket.udp()
    s:setpeername( "74.125.115.104", 80 )
    local ip, sock = s:getsockname()
    s:close()
    return ip
end

S.startServer = function()
    local clientList = {}
    local clientBuffer = {}
    socket = require("socket")

    tcp, err = socket.bind( S.getIP(), 63582 )  --create a server object
    print("tcp: "..tostring(tcp))
    print("err: "..tostring(err))
    tcp:settimeout( 0 )
    local ip,port = tcp:getsockname()
    print(port)
    print(ip)

    deltaTime = love.timer.getTime()*1000
    PULSE = function ()
        if (love.timer.getTime()*1000) - deltaTime >= 10 then -- pulses every 10 ms
            S.pulse()
        end
    end
end

function S.stopServer()
    print("Shutting down server.")
    PULSE = nil
    tcp:close()
    for i, v in pairs( clientList ) do
        v:close()
    end
end

function S.pulse() --Main loop
    repeat
        local client = tcp:accept()  --allow a new client to connect
        if client then
            local ip, port = client:getpeername()
            print( "Connection established: "..ip.." : "..port )
            client:settimeout( 0 )  --just check the socket and keep going
            --TO DO: implement a way to check to see if the client has connected previously
            --consider assigning the client a session ID and use it on reconnect.
                clientList[#clientList+1] = client
                local string = (binser.serialize(TileMap))
                clientBuffer[client] = { "MAP\n", string }  --just including something to send below
        end
    until not client
    local ready, writeReady, err = socket.select( clientList, nil, 0 )
    --print(clientList[1])
    if err == nil then
        for i = 1, #ready do  --list of clients who are available
            local client = ready[i]
            local allData = {}  --this holds all lines from a given client
            repeat
                local data, err = client:receive()  --get a line of data from the client, if any
                if data then
                    allData[#allData+1] = data
                end
            until not data

            if ( #allData > 0 ) then  --figure out what the client said to the server
                for i, thisData in ipairs( allData ) do
                    --print( "RECEIVED MSG: "..tostring(thisData) )
                    if thisData == "CLOSED" then -- Move to new cmd script
                        for i,v in pairs(clientList) do
                            if v == client then
                                local ip, port = client:getpeername()
                                print("Closing connection with "..ip..":"..port)
                                table.remove(clientList, i)
                                return true
                            end
                            --print("Kicking "..tostring(client).." - Not equal: "..tostring(v))
                        end
                        --table.remove(clientList, client)
                    end

                    local CMD, ARG = string.match(thisData, '(.*)%s(.*)')

                    if CMD == "MOVE" then
                        -- FOR NOW, MOVEMENT IS ONLY DONE IN CLIENT, EASILY HACKABLE..
                    end

                end
            end
        end

        for c, buffer in pairs( clientBuffer ) do
            local success = true
            for _, msg in pairs( buffer ) do  --might be empty
                --print("Sending message to "..tostring(c).." | Msg: "..msg)
                local data, err = c:send( msg )  --send the message to the client
                if err then
                    success = false
                    print("Error sending from buffer to client.")
                    break
                end
            end
            if success then
                clientBuffer[c] = {}
            end
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "return" then
        if PULSE then S.stopServer()
        else S.startServer() end
    end
end

function love.draw()
    if PULSE then
        love.graphics.printf("Connected #: "..#clientList.."\n(Press ENTER to stop server)", 0, 0, love.graphics.getWidth(), "center", r, sx, sy, ox, oy, kx, ky)
    else
        love.graphics.printf("Server Offline\n(Press ENTER to start server)", 0, 0, love.graphics.getWidth(), "center", r, sx, sy, ox, oy, kx, ky)
    end
end
function love.update(dt)
    if PULSE then PULSE() end
end

function love.quit()
    --timer.cancel( serverPulse )  --cancel timer
    if PULSE then S.stopServer() end
end


















--
