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
    ain = 0x00,
    in_floating = 0x04,
    ipd = 0x28,
    ipu = 0x48,
    out_od = 0x14,
    out_pp = 0x10,
    af_od = 0x1c,
    af_pp = 0x18,
};

pub const Config = struct {
    pin: Pin,
    speed: Speed,
    mode: Mode,
};

inner: *volatile micro.chip.types.GPIOA,

const GPIO = @This();

pub fn init(gpio: *GPIO, config: Config) void {
    var cur_mode = @enumToInt(config.mode) & @as(u32, 0x0F);
    if ((@enumToInt(config.mode) & @as(u32, 0x10)) != 0x00) {
        cur_mode |= @enumToInt(config.speed);
    }

    if ((@enumToInt(config.pin) & @as(u32, 0xFF)) != 0x00) {
        var tmp_reg = @bitCast(u32, gpio.inner.CRL);
        for (0x00..0x08) |pinpos| {
            var pos = @as(u32, 0x01) << @intCast(u5, pinpos);
            var cur_pin = @enumToInt(config.pin) & pos;

            if (cur_pin == pos) {
                pos = pinpos << 2;
                var pin_mask = @as(u32, 0x0F) << @intCast(u5, pos);
                tmp_reg &= ~pin_mask;
            }
        }
    }
}
