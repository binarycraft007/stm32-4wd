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
        .pin = .pin_1,
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    leds.red.init();

    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    leds.green = .{
        .pin = .pin_0,
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    leds.green.init();

    RCC.APB2ENR.modify(.{ .IOPAEN = 1 });
    leds.blue = .{
        .pin = .pin_7,
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOA,
    };
    leds.blue.init();
}

pub fn control(cmd: Command) void {
    leds.red.put(@intToEnum(GPIO.State, cmd.red));
    leds.green.put(@intToEnum(GPIO.State, cmd.green));
    leds.blue.put(@intToEnum(GPIO.State, cmd.blue));
}
