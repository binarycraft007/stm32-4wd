pub const micro = @import("microzig");
pub const Gpio = @import("hal/Gpio.zig");
pub const Timer = @import("hal/Timer.zig");
pub const time = @import("hal/time.zig");
pub const leds = @import("hal/leds.zig");
pub const motors = @import("hal/motors.zig");

pub fn init() void {
    // Reset the RCC clock configuration to the default
    // reset state(for debug purpose)

    // Set HSION bit
    micro.chip.peripherals.RCC.CR.modify(.{ .HSION = 1 });

    // Reset SW, HPRE, PPRE1, PPRE2, ADCPRE and MCO bits
    micro.chip.peripherals.RCC.CFGR.modify(.{
        .SW = 0,
        .SWS = 0,
        .HPRE = 0,
        .PPRE1 = 0,
        .PPRE2 = 0,
        .ADCPRE = 0,
        .MCO = 0,
    });

    // Reset HSEON, CSSON and PLLON bits
    micro.chip.peripherals.RCC.CR.modify(.{
        .HSEON = 0,
        .CSSON = 0,
        .PLLON = 0,
    });

    // Reset HSEBYP bit
    micro.chip.peripherals.RCC.CR.modify(.{ .HSEBYP = 0 });

    micro.chip.peripherals.RCC.CFGR.modify(.{
        .PLLSRC = 0,
        .PLLXTPRE = 0,
        .PLLMUL = 0,
        .OTGFSPRE = 0,
    });
    // Disable all interrupts and clear pending bits
    micro.chip.peripherals.RCC.CIR.write_raw(0x009F0000);
    micro.chip.peripherals.SCB.VTOR.write_raw(0x08000000 | 0x0);

    time.init();
    leds.init();
    motors.init();
}
