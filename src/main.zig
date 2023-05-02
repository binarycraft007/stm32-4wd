const std = @import("std");
const micro = @import("microzig");

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
}

pub fn main() !void {}
