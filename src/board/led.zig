const micro = @import("microzig");
const hal = @import("../hal.zig");

pub fn init() void {
    var gpio_red = hal.GPIO{
        .inner = micro.chip.peripherals.GPIOB,
    };
    gpio_red.init(.{
        .mode = .out_pp,
        .pin = .pin_1,
        .speed = .@"50_mhz",
    });
}
