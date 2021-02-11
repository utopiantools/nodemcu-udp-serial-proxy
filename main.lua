-- GLOBAL VARIABLES
DEBUG  = false
LOG2   = false -- log to secondary serial console

-- udp ports
PORT   = 52381
BAUD   = 38400

clientip = 0
clientport = 0
client = 0

localip = ''

dofile('helpers.lua')
dofile('credentials.lua')

-- log will print to the primary serial console
function log(s)
  if DEBUG or LOG2 then
    if LOG2 then
        uart.write(1, s .. '\n') -- secondary, one-way console
    else
        print(s)
    end
	end
end

-- sout will print to the bidirectional uart
function sout(s)
    uart.write(0, s)
end

function start_wifi()
    wifi.setmode(wifi.STATION)

    station_cfg={}
    station_cfg.ssid=SSID
    station_cfg.pwd=PWD
    station_cfg.auto=true
    wifi.sta.config(station_cfg)
    log("\nConnecting WiFi")
    
    -- async wait for wifi connection
    tmr.create():alarm(1000, tmr.ALARM_AUTO, function(t)
        blink()
        if wifi.sta.getip()== nil then
            log("Waiting for IP...")
        else
            t:stop()
            localip = wifi.sta.getip() -- we store our_ip, as we need it to setup udp socket properly
            log(" Your IP is ".. localip)
            start_udp()
        end
    end)
end

function start_udp()
    log('Starting UDP Socket')
    udpSocket = net.createUDPSocket()
    
    -- pass an IP here or will bind to 0.0.0.0 (all interfaces)
    udpSocket:listen(PORT)
    
    -- async wait for data
    udpSocket:on("receive", function(s, data, remoteport, remoteip)
        client = s
        clientip = remoteip
        clientport = remoteport
        debug(data)
        sout(data) -- echo to serial port
        blink(1,5)
    end)

    port, ip = udpSocket:getaddr()
    log(string.format("UDP socket listening on %s:%d", ip, port))
    blink(3)
    start_serial()
end

function start_serial()
    log('Listening for Serial Data')
    uart.on('data', string.char(0xff), function(data)
        blink(2,5)
        debug(data)
        if client ~= 0 then
            client:send(clientport, clientip, data);
        end
    end, 0)
end


-- Main Program
uart.setup(0, BAUD, 8, 0, 1, 0 ) -- echo off

gpio.mode(LEDPIN, gpio.OUTPUT)
led(off)
blink()

start_wifi() -- should give time to reload if serial crashes
