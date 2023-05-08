const std = @import("std");
const micro = @import("microzig");
const hal = micro.hal;

pub fn main() void {
    while (true) {
        hal.leds.control(.{ .red = .high, .green = .low, .blue = .low });
        hal.time.sleep_ms(300);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .low });
        hal.time.sleep_ms(400);
        hal.leds.control(.{ .red = .high, .green = .low, .blue = .low });
        hal.time.sleep_ms(300);

        hal.leds.control(.{ .red = .low, .green = .low, .blue = .high });
        hal.time.sleep_ms(300);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .low });
        hal.time.sleep_ms(400);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .high });
        hal.time.sleep_ms(300);

        hal.leds.control(.{ .red = .high, .green = .low, .blue = .low });
        hal.time.sleep_ms(100);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .low });
        hal.time.sleep_ms(50);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .high });
        hal.time.sleep_ms(100);
        hal.leds.control(.{ .red = .high, .green = .low, .blue = .low });
        hal.time.sleep_ms(100);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .low });
        hal.time.sleep_ms(50);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .high });
        hal.time.sleep_ms(100);
        hal.leds.control(.{ .red = .high, .green = .low, .blue = .low });
        hal.time.sleep_ms(100);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .low });
        hal.time.sleep_ms(50);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .high });
        hal.time.sleep_ms(100);
        hal.leds.control(.{ .red = .high, .green = .low, .blue = .low });
        hal.time.sleep_ms(100);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .low });
        hal.time.sleep_ms(50);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .high });
        hal.time.sleep_ms(100);

        hal.leds.control(.{ .red = .high, .green = .low, .blue = .low });
        hal.time.sleep_ms(500);
        hal.leds.control(.{ .red = .low, .green = .high, .blue = .low });
        hal.time.sleep_ms(500);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .high });
        hal.time.sleep_ms(500);
        hal.leds.control(.{ .red = .high, .green = .high, .blue = .low });
        hal.time.sleep_ms(500);
        hal.leds.control(.{ .red = .high, .green = .low, .blue = .high });
        hal.time.sleep_ms(500);
        hal.leds.control(.{ .red = .low, .green = .high, .blue = .high });
        hal.time.sleep_ms(500);
        hal.leds.control(.{ .red = .high, .green = .high, .blue = .high });
        hal.time.sleep_ms(500);
        hal.leds.control(.{ .red = .low, .green = .low, .blue = .low });
        hal.time.sleep_ms(500);
    }
}
