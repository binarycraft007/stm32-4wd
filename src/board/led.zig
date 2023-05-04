const micro = @import("microzig");
const RCC = micro.chip.peripherals.RCC;
const hal = @import("../hal.zig");

pub const Leds = enum {
    red,
    green,
    blue,
};

pub const Command = packed struct {
    red: bool,
    green: bool,
    blue: bool,
};

var gpio_red: hal.GPIO = undefined;
var gpio_green: hal.GPIO = undefined;
var gpio_blue: hal.GPIO = undefined;

pub fn init() void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    gpio_red = hal.GPIO{
        .mode = .out_pp,
        .pin = .pin_1,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    gpio_red.init();

    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    gpio_green = hal.GPIO{
        .mode = .out_pp,
        .pin = .pin_0,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    gpio_green.init();

    RCC.APB2ENR.modify(.{ .IOPAEN = 1 });
    gpio_blue = hal.GPIO{
        .mode = .out_pp,
        .pin = .pin_7,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOA,
    };
    gpio_blue.init();
}

pub fn set_on(led: Leds) void {
    switch (led) {
        .red => gpio_red.set_bits(),
        .green => gpio_green.set_bits(),
        .blue => gpio_blue.set_bits(),
    }
}

pub fn set_off(led: Leds) void {
    switch (led) {
        .red => gpio_red.reset_bits(),
        .green => gpio_green.reset_bits(),
        .blue => gpio_blue.reset_bits(),
    }
}

pub fn control(cmd: Command) void {
    if (cmd.red) set_on(.red) else set_off(.red);

    if (cmd.green) set_on(.green) else set_off(.green);

    if (cmd.blue) set_on(.blue) else set_off(.blue);
}
