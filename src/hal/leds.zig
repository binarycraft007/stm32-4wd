const micro = @import("microzig");
const RCC = micro.chip.peripherals.RCC;
const Gpio = micro.hal.Gpio;

var leds: Leds = .{
    .red = undefined,
    .green = undefined,
    .blue = undefined,
};

pub fn init() void {
    RCC.APB2ENR.modify(.{ .IOPBEN = 1 });
    RCC.APB2ENR.modify(.{ .IOPAEN = 1 });

    leds.init(.{
        .ports = .{
            .red = .GPIOB,
            .green = .GPIOB,
            .blue = .GPIOA,
        },
        .pins = .{
            .red = .{ .pin_01 = 1 },
            .green = .{ .pin_00 = 1 },
            .blue = .{ .pin_07 = 1 },
        },
    });
}

pub fn control(fields: anytype) void {
    inline for (@typeInfo(@TypeOf(fields)).Struct.fields) |field| {
        @field(leds, field.name).put(@field(fields, field.name));
    }
}

const Leds = struct {
    red: Gpio,
    green: Gpio,
    blue: Gpio,

    const InitOptions = struct {
        ports: struct {
            red: Gpio.Handles,
            green: Gpio.Handles,
            blue: Gpio.Handles,
        },
        pins: struct {
            red: Gpio.Pin,
            green: Gpio.Pin,
            blue: Gpio.Pin,
        },
    };

    fn init(self: *Leds, options: InitOptions) void {
        inline for (@typeInfo(Leds).Struct.fields) |field| {
            @field(self, field.name) = Gpio.init(.{
                .pin = @field(options.pins, field.name),
                .mode = .out_push_pull,
                .speed = .@"50_mhz",
                .handle = @field(options.ports, field.name),
            });
        }
    }
};
