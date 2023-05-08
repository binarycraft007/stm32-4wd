const micro = @import("microzig");
const RCC = micro.chip.peripherals.RCC;
const Gpio = micro.hal.Gpio;

const Leds = struct {
    red: Gpio,
    green: Gpio,
    blue: Gpio,
};

var leds: Leds = .{
    .red = undefined,
    .green = undefined,
    .blue = undefined,
};

pub fn init() void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    leds.red = Gpio.init(.{
        .pin = .{ .pin_01 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .handle = .GPIOB,
    });

    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    leds.green = Gpio.init(.{
        .pin = .{ .pin_00 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .handle = .GPIOB,
    });

    RCC.APB2ENR.modify(.{ .IOPAEN = 1 });
    leds.blue = Gpio.init(.{
        .pin = .{ .pin_07 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .handle = .GPIOA,
    });
}

pub fn control(fields: anytype) void {
    inline for (@typeInfo(@TypeOf(fields)).Struct.fields) |field| {
        @field(leds, field.name).put(@field(fields, field.name));
    }
}
