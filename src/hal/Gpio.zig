const std = @import("std");
const micro = @import("microzig");

pub const Pins = packed struct(u16) {
    pin_00: u1 = 0,
    pin_01: u1 = 0,
    pin_02: u1 = 0,
    pin_03: u1 = 0,
    pin_04: u1 = 0,
    pin_05: u1 = 0,
    pin_06: u1 = 0,
    pin_07: u1 = 0,
    pin_08: u1 = 0,
    pin_09: u1 = 0,
    pin_10: u1 = 0,
    pin_11: u1 = 0,
    pin_12: u1 = 0,
    pin_13: u1 = 0,
    pin_14: u1 = 0,
    pin_15: u1 = 0,
};

pub const Pin = union(enum) {
    pin_00: u1,
    pin_01: u1,
    pin_02: u1,
    pin_03: u1,
    pin_04: u1,
    pin_05: u1,
    pin_06: u1,
    pin_07: u1,
    pin_08: u1,
    pin_09: u1,
    pin_10: u1,
    pin_11: u1,
    pin_12: u1,
    pin_13: u1,
    pin_14: u1,
    pin_15: u1,
};

pub const Speed = enum {
    @"10_mhz",
    @"2_mhz",
    @"50_mhz",
};

pub const Mode = enum {
    in_analog,
    in_floating,
    in_pull_down,
    in_pull_up,

    out_push_pull,
    out_open_drain,
    alter_push_pull,
    alter_open_drain,
};

pub const State = enum(u1) {
    high = 1,
    low = 0,
};

pub const PortConfig = packed struct(u4) {
    mode: u2,
    config: u2,
};

pub const InitOptions = struct {
    pin: Pin,
    speed: Speed,
    mode: Mode,
    inner: *volatile micro.chip.types.GPIOA,
};

pins: Pins = .{},
speed: Speed,
mode: Mode,
inner: *volatile micro.chip.types.GPIOA,

const Gpio = @This();

pub fn init(options: InitOptions) Gpio {
    var gpio = Gpio{
        .speed = options.speed,
        .mode = options.mode,
        .inner = options.inner,
    };

    switch (options.pin) {
        inline else => |_, tag| {
            @field(gpio.pins, @tagName(tag)) = 1;
        },
    }

    // In input mode (MODE[1:0] = 00):
    // 00: Analog mode
    // 01: Floating input (reset state)
    // 10: Input with pull-up / pull-down
    // 11: Reserved
    // In output mode (MODE[1:0] > 00):
    // 00: General purpose output push-pull
    // 01: General purpose output Open-drain
    // 10: Alternate function output Push-pull
    // 11: Alternate function output Open-drain
    var config: u2 = blk: {
        switch (gpio.mode) {
            .in_analog,
            .out_push_pull,
            => break :blk 0x0,
            .in_floating,
            .out_open_drain,
            => break :blk 0x1,
            .in_pull_down,
            .in_pull_up,
            .alter_push_pull,
            => break :blk 0x2,
            .alter_open_drain => break :blk 0x3,
        }
    };

    // 00: Input mode (reset state)
    // 01: Output mode, max speed 10 MHz.
    // 10: Output mode, max speed 2 MHz.
    // 11: Output mode, max speed 50 MHz.
    var mode: u2 = blk: {
        switch (gpio.mode) {
            .in_analog,
            .in_floating,
            .in_pull_down,
            .in_pull_up,
            => break :blk 0x0,
            else => break :blk @enumToInt(gpio.speed) + 1,
        }
    };

    var reg_raw = @bitCast(u16, gpio.pins);
    switch (gpio.mode) {
        .in_pull_up => gpio.inner.BSRR.write_raw(reg_raw),
        .in_pull_down => gpio.inner.BRR.write_raw(reg_raw),
        else => {},
    }

    var config_raw = @intCast(u32, @bitCast(u4, PortConfig{
        .mode = mode,
        .config = config,
    }));

    switch (std.math.log2(@bitCast(u16, gpio.pins))) {
        0...7 => |index| {
            var tmp_reg = gpio.inner.CRL.raw;
            var pos = index << 2;
            var pin_mask = @as(u32, 0x0F) << @intCast(u5, pos);
            tmp_reg &= ~pin_mask;
            tmp_reg |= config_raw << @intCast(u5, pos);
            gpio.inner.CRL.write_raw(tmp_reg);
        },
        8...15 => |index| {
            var tmp_reg = gpio.inner.CRH.raw;
            var pos = (index - 8) << 2;
            var pin_mask = @as(u32, 0x0F) << @intCast(u5, pos);
            tmp_reg &= ~pin_mask;
            tmp_reg |= config_raw << @intCast(u5, pos);
            gpio.inner.CRH.write_raw(tmp_reg);
        },
        else => unreachable,
    }
    return gpio;
}

pub fn put(gpio: *Gpio, state: State) void {
    switch (state) {
        .high => gpio.inner.BSRR.write_raw(@bitCast(u16, gpio.pins)),
        .low => gpio.inner.BRR.write_raw(@bitCast(u16, gpio.pins)),
    }
}