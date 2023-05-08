const std = @import("std");
const micro = @import("microzig");

const TimHandles = enum {
    // advanced
    TIM1,
    TIM8,

    // general_advanced
    TIM2,
    TIM3,
    TIM4,
    TIM5,

    // general basic
    TIM9,
    TIM12,

    TIM10,
    TIM11,
    TIM13,
    TIM14,

    // basic
    TIM6,
    TIM7,
};

const InitOptions = struct {
    direction: enum {
        up,
        down,
    } = .up,
    center_alignment: enum {
        edge_aligned,
        center_aligned1,
        center_aligned2,
        center_aligned3,
    } = .edge_aligned,
    clock_division: enum {
        clock_division1,
        clock_division2,
        clock_division3,
    } = .clock_division1,
    reload_period: u16,
    prescaler: u16,
    handle: TimHandles,
    repetition_counter: u8 = undefined,
};

const OutputCompareMode = enum {
    timing,
    active,
    inactive,
    toggle,
    pwm1,
    pwm2,
};

const OutputCompareOptions = struct {
    mode: union(enum) {
        OC1M: OutputCompareMode,
        OC2M: OutputCompareMode,
        OC3M: OutputCompareMode,
        OC4M: OutputCompareMode,
    },
};

handle: union(enum) {
    basic: *volatile micro.chip.types.TIM6,
    advanced: *volatile micro.chip.types.TIM1,
    general_advanced: *volatile micro.chip.types.TIM2,
    general_basic1: *volatile micro.chip.types.TIM9,
    general_basic2: *volatile micro.chip.types.TIM10,
} = undefined,

const Tim = @This();

pub fn init(options: InitOptions) Tim {
    var tim = Tim{};
    switch (options.handle) {
        inline .TIM6, .TIM7 => |tag| {
            tim.handle.basic = @field(
                micro.chip.peripherals,
                @tagName(tag),
            );
        },
        inline .TIM1, .TIM8 => |tag| {
            tim.handle.advanced = @field(
                micro.chip.peripherals,
                @tagName(tag),
            );
        },
        inline .TIM2, .TIM3, .TIM4, .TIM5 => |tag| {
            tim.handle.general_advanced = @field(
                micro.chip.peripherals,
                @tagName(tag),
            );
        },
        inline .TIM9, .TIM12 => |tag| {
            tim.handle.general_basic1 = @field(
                micro.chip.peripherals,
                @tagName(tag),
            );
        },
        inline else => |tag| {
            tim.handle.general_basic2 = @field(
                micro.chip.peripherals,
                @tagName(tag),
            );
        },
    }

    switch (tim.handle) {
        inline .advanced, .general_advanced => |handle| {
            handle.CR1.modify(.{
                .DIR = @enumToInt(options.direction),
                .CMS = @enumToInt(options.center_alignment),
                .CKD = @enumToInt(options.clock_division),
            });
        },
        inline .basic => {},
        inline else => |handle| {
            handle.CR1.modify(.{
                .CKD = @enumToInt(options.clock_division),
            });
        },
    }

    switch (tim.handle) {
        inline else => |handle| {
            if (@hasDecl(@TypeOf(handle.*), "ARR")) {
                handle.ARR.modify(.{
                    .ARR = options.reload_period,
                });
            }

            if (@hasDecl(@TypeOf(handle.*), "PSC")) {
                handle.PSC.modify(.{
                    .PSC = options.prescaler,
                });
            }
            if (@hasDecl(@TypeOf(handle.*), "RCR")) {
                handle.PSC.modify(.{
                    .PSC = options.repetition_counter,
                });
            }
            handle.EGR.write_raw(0x0001);
        },
    }

    return tim;
}

pub fn init_output_compare(tim: *Tim, options: OutputCompareOptions) void {
    switch (tim.handle) {
        inline else => |handle| if (@hasDecl(@TypeOf(handle.*), "CCMR1_Output")) {
            switch (options.mode) {
                inline .OC1M, .OC2M => |value, tag| {
                    var field = @field(handle.CCMR1_Output, @tagName(tag));
                    field = @enumToInt(value);
                },
                inline .OC3M, .OC4M => |value, tag| {
                    var field = @field(handle.CCMR1_Output, @tagName(tag));
                    field = @enumToInt(value);
                },
            }
        },
    }
}
