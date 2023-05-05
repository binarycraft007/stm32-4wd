const micro = @import("microzig");
const RCC = micro.chip.peripherals.RCC;
const GPIO = micro.hal.GPIO;

pub const Command = packed struct {
    red: u1,
    green: u1,
    blue: u1,
};

const Leds = struct {
    red: GPIO,
    green: GPIO,
    blue: GPIO,
};

var leds: Leds = .{
    .red = undefined,
    .green = undefined,
    .blue = undefined,
};

pub fn init() void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    leds.red = .{
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    leds.red.init(.pin_1);

    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    leds.green = .{
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    leds.green.init(.pin_0);

    RCC.APB2ENR.modify(.{ .IOPAEN = 1 });
    leds.blue = .{
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOA,
    };
    leds.blue.init(.pin_7);
}

pub fn control(cmd: Command) void {
    leds.red.put(@intToEnum(GPIO.State, cmd.red));
    leds.green.put(@intToEnum(GPIO.State, cmd.green));
    leds.blue.put(@intToEnum(GPIO.State, cmd.blue));
}
