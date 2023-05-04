const micro = @import("microzig");
const STK = micro.chip.peripherals.STK;

// TODO compute system core clock;
const system_core_clock = 8_000_000;

var factor_us: u8 = 0;
var factor_ms: u16 = 0;

pub const TickUnit = enum {
    us,
    ms,
};

pub fn init() void {
    STK.CTRL.modify(.{ .CLKSOURCE = 0 });
    factor_us = system_core_clock / 8_000_000;
    factor_ms = @intCast(u16, factor_us) * 1000;
}

pub fn tick(unit: TickUnit, time: u32) void {
    var factor = blk: {
        switch (unit) {
            .us => break :blk factor_us,
            .ms => break :blk factor_ms,
        }
    };

    STK.LOAD_.write_raw(time * factor);
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
