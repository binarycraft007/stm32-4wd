const micro = @import("microzig");
const RCC = micro.chip.peripherals.RCC;
const Gpio = micro.hal.Gpio;

const Motors = struct {
    left: struct {
        front: Gpio,
        rear: Gpio,
    },
    right: struct {
        front: Gpio,
        rear: Gpio,
    },
};

var motors: Motors = .{
    .left = .{
        .front = undefined,
        .rear = undefined,
    },
    .right = .{
        .front = undefined,
        .rear = undefined,
    },
};

pub fn init() void {
    init_gpios();
}

fn init_gpios() void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    motors.left.front = Gpio.init(.{
        .pin = .{ .pin_09 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    });
    motors.left.rear = Gpio.init(.{
        .pin = .{ .pin_08 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    });
    motors.right.front = Gpio.init(.{
        .pin = .{ .pin_04 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    });
    motors.right.rear = Gpio.init(.{
        .pin = .{ .pin_05 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .inner = micro.chip.peripherals.GPIOB,
    });
    control_left(.{ .front = .high, .rear = .high });
    control_right(.{ .front = .high, .rear = .high });

    RCC.APB2ENR.modify(.{ .IOPBEN = 1, .AFIOEN = 1 });
}

pub fn forward() void {
    control_left(.{ .front = .high, .rear = .low });
    control_right(.{ .front = .high, .rear = .low });
}

pub fn backward() void {
    control_left(.{ .front = .low, .rear = .high });
    control_right(.{ .front = .low, .rear = .high });
}

pub fn stop() void {
    control_left(.{ .front = .low, .rear = .low });
    control_right(.{ .front = .low, .rear = .low });
}

pub fn turn_left() void {
    control_left(.{ .front = .low, .rear = .high });
    control_right(.{ .front = .high, .rear = .low });
}

pub fn turn_right() void {
    control_left(.{ .front = .high, .rear = .low });
    control_right(.{ .front = .low, .rear = .high });
}

pub fn control_left(fields: anytype) void {
    inline for (@typeInfo(@TypeOf(fields)).Struct.fields) |field| {
        @field(motors.left, field.name).put(@field(fields, field.name));
    }
}

pub fn control_right(fields: anytype) void {
    inline for (@typeInfo(@TypeOf(fields)).Struct.fields) |field| {
        @field(motors.right, field.name).put(@field(fields, field.name));
    }
}
