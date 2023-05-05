const std = @import("std");
const micro = @import("microzig");
const hal = micro.hal;

pub fn main() void {
    while (true) {
        hal.led.control(.{ .red = 1, .green = 0, .blue = 0 });
        hal.time.sleep_ms(300);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 0 });
        hal.time.sleep_ms(400);
        hal.led.control(.{ .red = 1, .green = 0, .blue = 0 });
        hal.time.sleep_ms(300);

        hal.led.control(.{ .red = 0, .green = 0, .blue = 1 });
        hal.time.sleep_ms(300);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 0 });
        hal.time.sleep_ms(400);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 1 });
        hal.time.sleep_ms(300);

        hal.led.control(.{ .red = 1, .green = 0, .blue = 0 });
        hal.time.sleep_ms(100);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 0 });
        hal.time.sleep_ms(50);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 1 });
        hal.time.sleep_ms(100);
        hal.led.control(.{ .red = 1, .green = 0, .blue = 0 });
        hal.time.sleep_ms(100);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 0 });
        hal.time.sleep_ms(50);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 1 });
        hal.time.sleep_ms(100);
        hal.led.control(.{ .red = 1, .green = 0, .blue = 0 });
        hal.time.sleep_ms(100);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 0 });
        hal.time.sleep_ms(50);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 1 });
        hal.time.sleep_ms(100);
        hal.led.control(.{ .red = 1, .green = 0, .blue = 0 });
        hal.time.sleep_ms(100);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 0 });
        hal.time.sleep_ms(50);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 1 });
        hal.time.sleep_ms(100);

        hal.led.control(.{ .red = 1, .green = 0, .blue = 0 });
        hal.time.sleep_ms(500);
        hal.led.control(.{ .red = 0, .green = 1, .blue = 0 });
        hal.time.sleep_ms(500);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 1 });
        hal.time.sleep_ms(500);
        hal.led.control(.{ .red = 1, .green = 1, .blue = 0 });
        hal.time.sleep_ms(500);
        hal.led.control(.{ .red = 1, .green = 0, .blue = 1 });
        hal.time.sleep_ms(500);
        hal.led.control(.{ .red = 0, .green = 1, .blue = 1 });
        hal.time.sleep_ms(500);
        hal.led.control(.{ .red = 1, .green = 1, .blue = 1 });
        hal.time.sleep_ms(500);
        hal.led.control(.{ .red = 0, .green = 0, .blue = 0 });
        hal.time.sleep_ms(500);
    }
}
