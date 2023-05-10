const micro = @import("microzig");
const RCC = micro.chip.peripherals.RCC;
const Gpio = micro.hal.Gpio;
const Tim = micro.hal.Tim;

var motors: Motors = .{
    .left = undefined,
    .right = undefined,
};

const Pwms = struct {
    left: struct {
        gpio: Gpio,
        tim: Tim,
    },
    right: struct {
        gpio: Gpio,
        tim: Tim,
    },
};

const PwmInitOptions = struct {
    left: struct {
        period: u16,
        prescaler: u16,
    },
    right: struct {
        period: u16,
        prescaler: u16,
    },
};

var pwms: Pwms = .{
    .left = undefined,
    .right = undefined,
};

pub fn init() void {
    init_gpios();
    init_pwms(.{
        .left = .{ .period = 7200, .prescaler = 0 },
        .right = .{ .period = 7200, .prescaler = 0 },
    });
}

inline fn init_gpios() void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1, .AFIOEN = 1 });
    // Release PB4 as GPIO instead of debug
    micro.chip.peripherals.AFIO.MAPR.modify(.{
        .SWJ_CFG = 0b010, // JTAG Disabled, SW Enabled
    });
    motors.init(.{
        .ports = .{
            .left = .{
                .front = .GPIOB,
                .rear = .GPIOB,
            },
            .right = .{
                .front = .GPIOB,
                .rear = .GPIOB,
            },
        },
        .pins = .{
            .left = .{
                .front = .{ .pin_09 = 1 },
                .rear = .{ .pin_08 = 1 },
            },
            .right = .{
                .front = .{ .pin_04 = 1 },
                .rear = .{ .pin_05 = 1 },
            },
        },
    });
    control(.left, .{ .front = .low, .rear = .low });
    control(.right, .{ .front = .low, .rear = .low });
}

inline fn init_pwms(options: PwmInitOptions) void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1, .AFIOEN = 1 });
    RCC.APB1ENR.modify(.{ .TIM4EN = 1 });

    pwms.left = .{
        .gpio = Gpio.init(.{
            .pin = .{ .pin_07 = 1 },
            .mode = .alt_push_pull,
            .speed = .@"50_mhz",
            .handle = .GPIOB,
        }),
        .tim = Tim.init(.{
            .handle = .TIM4,
            .direction = .up,
            .clock_division = .clock_division1,
            .period = options.left.period,
            .prescaler = options.left.prescaler,
        }),
    };
    pwms.left.tim.init_output_compare(.{
        .mode = .{ .OC2M = .pwm1 },
        .pulse = .{ .CCR2 = 0 },
        .output_state = .{ .CC2E = 1 },
        .output_polarity = .{ .CC2P = .active_high },
    });

    pwms.right = .{
        .gpio = Gpio.init(.{
            .pin = .{ .pin_06 = 1 },
            .mode = .alt_push_pull,
            .speed = .@"50_mhz",
            .handle = .GPIOB,
        }),
        .tim = Tim.init(.{
            .handle = .TIM4,
            .direction = .up,
            .clock_division = .clock_division1,
            .period = options.right.period,
            .prescaler = options.right.prescaler,
        }),
    };
    pwms.right.tim.init_output_compare(.{
        .mode = .{ .OC1M = .pwm1 },
        .pulse = .{ .CCR1 = 0 },
        .output_state = .{ .CC1E = 1 },
        .output_polarity = .{ .CC1P = .active_high },
    });

    pwms.left.tim.modify("CCMR1_Output", .{ .OC2PE = 1 });
    pwms.left.tim.modify("CR1", .{ .CEN = 1 });
    pwms.right.tim.modify("CCMR1_Output", .{ .OC1PE = 1 });
    pwms.right.tim.modify("CR1", .{ .CEN = 1 });
}

pub fn forward(speed: u16) void {
    control(.left, .{ .front = .high, .rear = .low });
    control(.right, .{ .front = .high, .rear = .low });
    pwm_control(.left, speed);
    pwm_control(.right, speed);
}

pub fn backward(speed: u16) void {
    control(.left, .{ .front = .low, .rear = .high });
    control(.right, .{ .front = .low, .rear = .high });
    pwm_control(.left, speed);
    pwm_control(.right, speed);
}

pub fn stop() void {
    control(.left, .{ .front = .low, .rear = .low });
    control(.right, .{ .front = .low, .rear = .low });
    pwm_control(.left, 0);
    pwm_control(.right, 0);
}

pub fn turn_left(speed: u16) void {
    control(.left, .{ .front = .low, .rear = .low });
    control(.right, .{ .front = .high, .rear = .low });
    pwm_control(.left, 0);
    pwm_control(.right, speed);
}

pub fn turn_right(speed: u16) void {
    control(.left, .{ .front = .high, .rear = .low });
    control(.right, .{ .front = .low, .rear = .low });
    pwm_control(.left, speed);
    pwm_control(.right, 0);
}

pub fn spin_left(speed: u16) void {
    control(.left, .{ .front = .low, .rear = .high });
    control(.right, .{ .front = .high, .rear = .low });
    pwm_control(.left, speed);
    pwm_control(.right, speed);
}

pub fn spin_right(speed: u16) void {
    control(.left, .{ .front = .high, .rear = .low });
    control(.right, .{ .front = .low, .rear = .high });
    pwm_control(.left, speed);
    pwm_control(.right, speed);
}

const ControlType = enum {
    left,
    right,
};

pub fn control(comptime side: ControlType, fields: anytype) void {
    inline for (@typeInfo(@TypeOf(fields)).Struct.fields) |field| {
        @field(@field(motors, @tagName(side)), field.name).put(
            @field(fields, field.name),
        );
    }
}

pub fn pwm_control(comptime side: ControlType, speed: u16) void {
    switch (side) {
        inline .left => {
            pwms.left.tim.modify("CCR2", .{ .CCR2 = speed });
        },
        inline .right => {
            pwms.right.tim.modify("CCR1", .{ .CCR1 = speed });
        },
    }
}

const Motors = struct {
    left: struct {
        front: Gpio,
        rear: Gpio,
    },
    right: struct {
        front: Gpio,
        rear: Gpio,
    },

    const InitOptions = struct {
        ports: struct {
            right: struct {
                front: Gpio.Handles,
                rear: Gpio.Handles,
            },
            left: struct {
                front: Gpio.Handles,
                rear: Gpio.Handles,
            },
        },
        pins: struct {
            right: struct {
                front: Gpio.Pin,
                rear: Gpio.Pin,
            },
            left: struct {
                front: Gpio.Pin,
                rear: Gpio.Pin,
            },
        },
    };

    fn init(self: *Motors, options: InitOptions) void {
        inline for (@typeInfo(Motors).Struct.fields) |side| {
            const T = @TypeOf(@field(self, side.name));
            inline for (@typeInfo(T).Struct.fields) |gpio| {
                const pins = options.pins;
                const ports = options.ports;
                @field(@field(self, side.name), gpio.name) = Gpio.init(
                    .{
                        .pin = @field(@field(pins, side.name), gpio.name),
                        .mode = .out_push_pull,
                        .speed = .@"50_mhz",
                        .handle = @field(@field(ports, side.name), gpio.name),
                    },
                );
            }
        }
    }
};
