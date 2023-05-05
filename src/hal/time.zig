const micro = @import("microzig");
const STK = micro.chip.peripherals.STK;

// TODO compute system core clock;
const system_core_clock = 8_000_000;

pub fn init() void {
    STK.CTRL.modify(.{ .CLKSOURCE = 0 });
}

pub fn sleep_ms(time_ms: u32) void {
    sleep_us(time_ms * 1000);
}

pub fn sleep_us(time_us: u32) void {
    const factor = system_core_clock / 8_000_000;

    STK.LOAD_.write_raw(time_us * factor);
    STK.VAL.write_raw(0x00);
    STK.CTRL.modify(.{ .ENABLE = 1 });

    defer {
        STK.CTRL.modify(.{ .ENABLE = 0 });
        STK.VAL.write_raw(0x00);
    }

    while (true) {
        var temp = STK.CTRL.read();
        if (temp.ENABLE != 1 or temp.COUNTFLAG == 1) {
            break;
        }
    }
}
