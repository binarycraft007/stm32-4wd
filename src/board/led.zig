const micro = @import("microzig");
const RCC = micro.chip.peripherals.RCC;
const hal = @import("../hal.zig");

pub const Leds = enum {
    red,
    green,
    blue,
};

pub const Command = packed struct {
    red: u1,
    green: u1,
    blue: u1,
};

var gpio_red: hal.GPIO = undefined;
var gpio_green: hal.GPIO = undefined;
var gpio_blue: hal.GPIO = undefined;

pub fn init() void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    gpio_red = .{
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    gpio_red.init(.pin_1);

    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    gpio_green = .{
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    gpio_green.init(.pin_0);

    RCC.APB2ENR.modify(.{ .IOPAEN = 1 });
    gpio_blue = .{
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOA,
    };
    gpio_blue.init(.pin_7);
}

pub fn control(cmd: Command) void {
    switch (cmd.red) {
        1 => gpio_red.set_pin(),
        0 => gpio_red.reset_pin(),
    }

    switch (cmd.green) {
        1 => gpio_green.set_pin(),
        0 => gpio_green.reset_pin(),
    }

    switch (cmd.blue) {
        1 => gpio_blue.set_pin(),
        0 => gpio_blue.reset_pin(),
    }
}
