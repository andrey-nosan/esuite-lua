--   8 analog via cd4051 multiplexer  NYT

if not adc.force_init_mode then
    print("*** You need to flash newer BIN version -HALTED ***")
    return
end

if adc.force_init_mode(adc.INIT_ADC) then  
    node.restart()  
    return 
end  -- if adc mode was wrong, swap & restart correctly (new nodemcu feature May 2016)


adc = clone(adc) -- a ram-based clone

function adc.init8(adr0, adr1, adr2)  -- ()  or (a0)   or (a0, a1, a2)
    adc.adr0 = adr0 or 6
    adc.adr1 = adr1 or (adc.adr0+1)
    adc.adr2 = adr2 or (adc.adr0+2)
    -- d6 d7 d8 default for cd4051 control A/lsb B C/msb (3 consecutive gpios?)
    gpio.mode(adc.adr0, gpio.OUTPUT)
    gpio.mode(adc.adr1, gpio.OUTPUT)
    gpio.mode(adc.adr2, gpio.OUTPUT)
end

function adc.read(channel)  -- 0-7
    if reg >= 8 then return adc.parent.read(channel) end
    if adc.adr0 then 
        gpio.write(adc.adr0, bit.isset(channel,0) and 1 or 0)    -- D6 is lsb input A
        gpio.write(adc.adr1, bit.isset(channel,1) and 1 or 0)
        gpio.write(adc.adr2, bit.isset(channel,2) and 1 or 0)  -- D8 is msb input C
    end
    return adc.original.read(0)  
end


