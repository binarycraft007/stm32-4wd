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
        .mode = .out_pp,
        .pin = .pin_1,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    gpio_red.init();

    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    gpio_green = .{
        .mode = .out_pp,
        .pin = .pin_0,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    };
    gpio_green.init();

    RCC.APB2ENR.modify(.{ .IOPAEN = 1 });
    gpio_blue = .{
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
    switch (cmd.red) {
        1 => set_on(.red),
        0 => set_off(.red),
    }

    switch (cmd.green) {
        1 => set_on(.green),
        0 => set_off(.green),
    }

    switch (cmd.blue) {
        1 => set_on(.blue),
        0 => set_off(.blue),
    }
}
