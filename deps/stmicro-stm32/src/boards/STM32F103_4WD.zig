pub const micro = @import("microzig");

pub const cpu_frequency = 72_000_000;

pub const pin_map = .{
    // circle of LEDs

    // red
    .LD1 = "PB1",
    // green
    .LD2 = "PB0",
    // blue
    .LD3 = "PA7",
};
