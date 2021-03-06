local S = {}

local socket = require( "socket" )

local clientList = {}
local clientBuffer = {}

S.getIP = function()
    local s = socket.udp()
    s:setpeername( "74.125.115.104", 80 )
    local ip, sock = s:getsockname()
    print( "myIP:", ip, sock )
    return ip
end

S.createServer = function()

    local tcp, err = socket.bind( S.getIP(), 22222 )  --create a server object
    tcp:settimeout( 0 )

    local function sPulse()
        repeat
            print("pulsed")
            local client = tcp:accept()  --allow a new client to connect
            if client then
                print( "found client" )
                client:settimeout( 0 )  --just check the socket and keep going
                --TO DO: implement a way to check to see if the client has connected previously
                --consider assigning the client a session ID and use it on reconnect.
                clientList[#clientList+1] = client
                clientBuffer[client] = { "hello_client\n" }  --just including something to send below
            end
        until not client

        local ready, writeReady, err = socket.select( clientList, clientList, 0 )
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
                        print( "thisData: ", thisData )
                        --do stuff with data
                    end
                end
            end

            for sock, buffer in pairs( clientBuffer ) do
                for _, msg in pairs( buffer ) do  --might be empty
                    local data, err = sock:send( msg )  --send the message to the client
                end
            end
        end
    end

    --pulse 10 times per second
    --local serverPulse = timer.performWithDelay( 100, sPulse, 0 )
    local deltaTime = love.timer.getTime()*1000
    serverPulse = function ()
        if (love.timer.getTime()*1000) - deltaTime >= 100 then
            print("pulsiin")
            sPulse()
        end
    end

    local function stopServer()
        --timer.cancel( serverPulse )  --cancel timer
        tcp:close()
        for i, v in pairs( clientList ) do
            v:close()
        end
    end
    return stopServer
end

return S
