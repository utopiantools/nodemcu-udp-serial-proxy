_ison = false

function led(turnon)
    if turnon == nil then
        turnon = not _ison
    end
    if turnon then
        gpio.write(LEDPIN, gpio.LOW)
    else
        gpio.write(LEDPIN, gpio.HIGH)
    end
    _ison = turnon
end

function blink(num, mson, msoff)
    local num = num or 1
    local mson = mson or 70
    local msoff = msoff or 70
    local counter = 1
    led(true)
    tmr.create():alarm(mson, tmr.ALARM_AUTO, function(t)
        led()
        if _ison then
            counter = counter + 1
            t:interval(mson)
            -- t:start()
        else
            t:interval(msoff)
            if counter == num then
                -- t:start()
                t:unregister()
            end
        end
    end)
end

function hex(str)
    return (str:gsub('.', function (c)
        -- return string.char(tonumber(c,16))
        return string.format('%02X', string.byte(c))
    end))
end

function debug(str)
	if DEBUG then
		print(hex(str))
	end
end
