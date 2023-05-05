const std = @import("std");
const micro = @import("microzig");

pub const Pin = enum {
    pin_0,
    pin_1,
    pin_2,
    pin_3,
    pin_4,
    pin_5,
    pin_6,
    pin_7,
    pin_8,
    pin_9,
    pin_10,
    pin_11,
    pin_12,
    pin_13,
    pin_14,
    pin_15,
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

pin: Pin = undefined,
speed: Speed,
mode: Mode,
inner: *volatile micro.chip.types.GPIOA,

const GPIO = @This();

pub fn init(gpio: *GPIO, comptime pin: Pin) void {
    gpio.pin = pin;

    var reg = blk: {
        switch (@enumToInt(pin)) {
            0...7 => break :blk gpio.inner.CRL,
            8...15 => break :blk gpio.inner.CRH,
        }
    };

    var config: u2 = blk: {
        switch (gpio.mode) {
            .in_analog, .out_push_pull => break :blk 0x0,
            .in_floating, .out_open_drain => break :blk 0x1,
            .in_pull_down, .in_pull_up, .alter_push_pull => break :blk 0x2,
            .alter_open_drain => break :blk 0x3,
        }
    };

    var mode: u2 = blk: {
        switch (gpio.mode) {
            .in_analog, .in_floating, .in_pull_down, .in_pull_up => break :blk 0x0,
            else => {
                switch (gpio.speed) {
                    .@"10_mhz" => break :blk 0x1,
                    .@"2_mhz" => break :blk 0x2,
                    .@"50_mhz" => break :blk 0x3,
                }
            },
        }
    };

    const index = std.fmt.comptimePrint("{d}", .{@enumToInt(pin)});
    switch (gpio.mode) {
        .in_pull_up => set_reg_field(gpio.inner.BSRR, "BS" ++ index, 0x1),
        .in_pull_down => set_reg_field(gpio.inner.BRR, "BR" ++ index, 0x1),
        else => {},
    }
    set_reg_field(reg, "CNF" ++ index, config);
    set_reg_field(reg, "MODE" ++ index, mode);
}

pub fn set_pin(gpio: *GPIO) void {
    gpio.inner.BSRR.write_raw(@enumToInt(gpio.pin));
}

pub fn reset_pin(gpio: *GPIO) void {
    gpio.inner.BRR.write_raw(@enumToInt(gpio.pin));
}

fn set_reg_field(reg: anytype, comptime field_name: anytype, value: anytype) void {
    var reg_var = reg;
    var temp = reg_var.read();
    @field(temp, field_name) = value;
    reg_var.write(temp);
}
