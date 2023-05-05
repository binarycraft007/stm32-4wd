pub const micro = @import("microzig");

pub const Pin = enum(u16) {
    pin_0 = 0x0001,
    pin_1 = 0x0002,
    pin_2 = 0x0004,
    pin_3 = 0x0008,
    pin_4 = 0x0010,
    pin_5 = 0x0020,
    pin_6 = 0x0040,
    pin_7 = 0x0080,
    pin_8 = 0x0100,
    pin_9 = 0x0200,
    pin_10 = 0x0400,
    pin_11 = 0x0800,
    pin_12 = 0x1000,
    pin_13 = 0x2000,
    pin_14 = 0x4000,
    pin_15 = 0x8000,
    pin_all = 0xFFFF,
};

pub const Speed = enum(u3) {
    @"10_mhz" = 1,
    @"2_mhz",
    @"50_mhz",
};

pub const Mode = enum(u32) {
    in_analog = 0x00,
    in_floating = 0x04,
    in_pull_up = 0x28,
    in_pull_down = 0x48,
    out_open_drain = 0x14,
    out_push_pull = 0x10,
    alter_open_drain = 0x1c,
    alter_push_pull = 0x18,
};

pub const State = enum(u1) {
    high = 1,
    low = 0,
};

pin: Pin,
speed: Speed,
mode: Mode,
inner: *volatile micro.chip.types.GPIOA,

const GPIO = @This();

pub fn init(gpio: *GPIO) void {
    // GPIO Mode Configuration
    var cur_mode = @enumToInt(gpio.mode) & @as(u32, 0x0F);
    if ((@enumToInt(gpio.mode) & @as(u32, 0x10)) != 0x00) {
        cur_mode |= @enumToInt(gpio.speed);
    }

    // GPIO CRL Configuration
    if ((@enumToInt(gpio.pin) & @as(u32, 0xFF)) != 0x00) {
        var tmp_reg = @bitCast(u32, gpio.inner.CRL.read());
        inline for (0x00..0x08) |pinpos| {
            var pos = @as(u32, 0x01) << @intCast(u5, pinpos);
            var cur_pin = @enumToInt(gpio.pin) & pos;

            if (cur_pin == pos) {
                pos = pinpos << 2;
                var pin_mask = @as(u32, 0x0F) << @intCast(u5, pos);
                tmp_reg &= ~pin_mask;
                tmp_reg |= (cur_mode << @intCast(u5, pos));
                if (gpio.mode == .in_pull_down) {
                    gpio.inner.BRR.write_raw(@as(u32, 0x01) << @intCast(u5, pinpos));
                } else if (gpio.mode == .in_pull_up) {
                    gpio.inner.BSRR.write_raw(@as(u32, 0x01) << @intCast(u5, pinpos));
                }
            }
        }
        gpio.inner.CRL.write_raw(tmp_reg);
    }

    // GPIO CRH Configuration
    if (@enumToInt(gpio.pin) > 0x00FF) {
        var tmp_reg = @bitCast(u32, gpio.inner.CRH.read());
        inline for (0x00..0x08) |pinpos| {
            var pos = @as(u32, 0x01) << @intCast(u5, pinpos + 0x08);
            var cur_pin = @enumToInt(gpio.pin) & pos;

            if (cur_pin == pos) {
                pos = pinpos << 2;
                var pin_mask = @as(u32, 0x0F) << @intCast(u5, pos);
                tmp_reg &= ~pin_mask;
                tmp_reg |= (cur_mode << @intCast(u5, pos));
                if (gpio.mode == .in_pull_down) {
                    gpio.inner.BRR.write_raw(@as(u32, 0x01) << @intCast(u5, pinpos + 0x08));
                } else if (gpio.mode == .in_pull_up) {
                    gpio.inner.BSRR.write_raw(@as(u32, 0x01) << @intCast(u5, pinpos + 0x08));
                }
            }
        }
        gpio.inner.CRH.write_raw(tmp_reg);
    }
}

pub fn put(gpio: *GPIO, state: State) void {
    switch (state) {
        .high => gpio.inner.BSRR.write_raw(@enumToInt(gpio.pin)),
        .low => gpio.inner.BRR.write_raw(@enumToInt(gpio.pin)),
    }
}
