const micro = @import("microzig");
const RCC = micro.chip.peripherals.RCC;
const Gpio = micro.hal.Gpio;
const Tim = micro.hal.Tim;

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
    .left = undefined,
    .right = undefined,
};

const Pwms = struct { pwma: struct {
    gpio: Gpio,
    tim: Tim,
}, pwmb: struct {
    gpio: Gpio,
    tim: Tim,
} };

var pwms: Pwms = .{
    .pwma = undefined,
    .pwmb = undefined,
};

pub fn init() void {
    init_gpios();
    init_pwm();
}

fn init_gpios() void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    motors.left.front = Gpio.init(.{
        .pin = .{ .pin_09 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .handle = .GPIOB,
    });
    motors.left.rear = Gpio.init(.{
        .pin = .{ .pin_08 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .handle = .GPIOB,
    });
    motors.right.front = Gpio.init(.{
        .pin = .{ .pin_04 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .handle = .GPIOB,
    });
    motors.right.rear = Gpio.init(.{
        .pin = .{ .pin_05 = 1 },
        .mode = .out_push_pull,
        .speed = .@"50_mhz",
        .handle = .GPIOB,
    });
    control_left(.{ .front = .high, .rear = .high });
    control_right(.{ .front = .high, .rear = .high });
}

fn init_pwm() void {
    micro.chip.peripherals.AFIO.MAPR.modify(.{ .SWJ_CFG = 0b010 });

    RCC.APB2ENR.modify(.{ .IOPBEN = 1, .AFIOEN = 1 });
    RCC.APB1ENR.modify(.{ .TIM4EN = 1 });
    pwms.pwma = .{
        .gpio = Gpio.init(.{
            .pin = .{ .pin_07 = 1 },
            .mode = .alter_push_pull,
            .speed = .@"50_mhz",
            .handle = .GPIOB,
        }),
        .tim = Tim.init(.{
            .handle = .TIM4,
            .direction = .up,
            .clock_division = .clock_division1,
            .reload_period = 7200,
            .prescaler = 0,
        }),
    };
    pwms.pwma.tim.init_output_compare(.{ .mode = .{ .OC2M = .pwm1 } });
    switch (pwms.pwma.tim.handle) {
        inline else => |handle| {
            if (@hasDecl(@TypeOf(handle.*), "CCMR1_Output")) {
                handle.CCMR1_Output.modify(.{ .OC2PE = 1 });
            }
            if (@hasDecl(@TypeOf(handle.*), "CR1")) {
                handle.CR1.modify(.{ .CEN = 1 });
            }
        },
    }

    RCC.APB2ENR.modify(.{ .IOPBEN = 1, .AFIOEN = 1 });
    RCC.APB1ENR.modify(.{ .TIM4EN = 1 });
    pwms.pwmb = .{
        .gpio = Gpio.init(.{
            .pin = .{ .pin_06 = 1 },
            .mode = .alter_push_pull,
            .speed = .@"50_mhz",
            .handle = .GPIOB,
        }),
        .tim = Tim.init(.{
            .handle = .TIM4,
            .direction = .up,
            .clock_division = .clock_division1,
            .reload_period = 7200,
            .prescaler = 0,
        }),
    };
    pwms.pwmb.tim.init_output_compare(.{ .mode = .{ .OC1M = .pwm1 } });
    switch (pwms.pwmb.tim.handle) {
        inline else => |handle| {
            if (@hasDecl(@TypeOf(handle.*), "CCMR1_Output")) {
                handle.CCMR1_Output.modify(.{ .OC1PE = 1 });
            }
            if (@hasDecl(@TypeOf(handle.*), "CR1")) {
                handle.CR1.modify(.{ .CEN = 1 });
            }
        },
    }
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
