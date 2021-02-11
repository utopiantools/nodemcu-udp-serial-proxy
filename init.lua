-- GLOBAL VARIABLES
LEDPIN = 4 -- on Pin 4
DEBUG  = true

function startup()
    print("starting main.lua")
    dofile('main.lua')
end

-- finish init
gpio.mode(LEDPIN, gpio.OUTPUT)
tmr.create():alarm(5000, tmr.ALARM_SINGLE, startup)
