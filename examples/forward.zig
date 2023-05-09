const std = @import("std");
const micro = @import("microzig");
const hal = micro.hal;

pub fn main() void {
    while (true) {
        hal.motors.forward(3600);
        hal.time.sleep_ms(1000);
        hal.motors.backward(3600);
        hal.time.sleep_ms(1000);
    }
}
