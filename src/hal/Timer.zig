const std = @import("std");
const micro = @import("microzig");
const peripherals = micro.chip.peripherals;

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
    period: u16,
    prescaler: u16,
    handle: TimHandles,
    repetition_counter: u8 = 0,
};

const OutputCompareMode = enum {
    timing,
    active,
    inactive,
    toggle,
    force_inactive,
    force_active,
    pwm1,
    pwm2,
};

const OutputPolarity = enum {
    active_high,
    active_low,
};

const OutputCompareOptions = struct {
    pulse: union(enum) {
        CCR1: u16,
        CCR2: u16,
        CCR3: u16,
        CCR4: u16,
    },
    mode: union(enum) {
        OC1M: OutputCompareMode,
        OC2M: OutputCompareMode,
        OC3M: OutputCompareMode,
        OC4M: OutputCompareMode,
    },
    idle_state: union(enum) {
        OIS1: u1,
        OIS2: u1,
        OIS3: u1,
        OIS4: u1,
    } = undefined,
    idle_state_n: union(enum) {
        OIS1N: u1,
        OIS2N: u1,
        OIS3N: u1,
    } = undefined,
    output_state: union(enum) {
        CC1E: u1,
        CC2E: u1,
        CC3E: u1,
        CC4E: u1,
    },
    output_polarity: union(enum) {
        CC1P: OutputPolarity,
        CC2P: OutputPolarity,
        CC3P: OutputPolarity,
        CC4P: OutputPolarity,
    },
    output_n_state: union(enum) {
        CC1NE: u1,
        CC2NE: u1,
        CC3NE: u1,
    } = undefined,
    output_n_polarity: union(enum) {
        CC1NP: OutputPolarity,
        CC2NP: OutputPolarity,
        CC3NP: OutputPolarity,
    } = undefined,
};

handle: union(enum) {
    basic: *volatile micro.chip.types.TIM6,
    advanced: *volatile micro.chip.types.TIM1,
    general_advanced: *volatile micro.chip.types.TIM2,
    general_basic1: *volatile micro.chip.types.TIM9,
    general_basic2: *volatile micro.chip.types.TIM10,
},

const Tim = @This();

pub fn init(options: InitOptions) Tim {
    var tim: Tim = blk: {
        break :blk switch (options.handle) {
            inline .TIM6, .TIM7 => |tag| .{
                .handle = .{
                    .basic = @field(peripherals, @tagName(tag)),
                },
            },
            inline .TIM1, .TIM8 => |tag| .{
                .handle = .{
                    .advanced = @field(peripherals, @tagName(tag)),
                },
            },
            inline .TIM2, .TIM3, .TIM4, .TIM5 => |tag| .{
                .handle = .{
                    .general_advanced = @field(peripherals, @tagName(tag)),
                },
            },
            inline .TIM9, .TIM12 => |tag| .{
                .handle = .{
                    .general_basic1 = @field(peripherals, @tagName(tag)),
                },
            },
            inline else => |tag| .{
                .handle = .{
                    .general_basic2 = @field(peripherals, @tagName(tag)),
                },
            },
        };
    };

    switch (tim.handle) {
        inline else => |handle| {
            if (@hasField(@TypeOf(handle.*), "CR1")) {
                if (@hasField(@TypeOf(handle.CR1), "CMS")) {
                    handle.CR1.modify(.{
                        .DIR = @enumToInt(options.direction),
                        .CMS = @enumToInt(options.center_alignment),
                        .CKD = @enumToInt(options.clock_division),
                    });
                } else {
                    if (@hasField(@TypeOf(handle.CR1), "CKD")) {
                        handle.CR1.modify(.{
                            .CKD = @enumToInt(options.clock_division),
                        });
                    }
                }
            }

            handle.ARR.modify(.{ .ARR = options.period });
            handle.PSC.modify(.{ .PSC = options.prescaler });

            if (@hasField(@TypeOf(handle.*), "RCR")) {
                handle.RCR.modify(.{ .REP = options.repetition_counter });
            }
            handle.EGR.modify(.{ .UG = 1 });
        },
    }

    return tim;
}

pub fn init_output_compare(tim: *Tim, options: OutputCompareOptions) void {
    switch (tim.handle) {
        inline else => |handle| {
            // Disable the Channel X: Reset the CCXE Bit,
            // CCxS bits are writable only when the channel
            // is OFF (CCxE = 0 in TIMx_CCER).
            if (@hasField(@TypeOf(handle.*), "CCER")) {
                var tmp_ccer = handle.CCER.read();
                switch (options.output_state) {
                    inline else => |_, tag| {
                        if (@hasField(@TypeOf(tmp_ccer), @tagName(tag))) {
                            @field(tmp_ccer, @tagName(tag)) = 0;
                        }
                    },
                }
                handle.CCER.write(tmp_ccer);
            }
            if (@hasField(@TypeOf(handle.*), "CR2")) {
                var tmp_cr2 = handle.CR2.read();
                switch (options.idle_state) {
                    inline else => |v, tag| {
                        if (@hasField(@TypeOf(tmp_cr2), @tagName(tag))) {
                            @field(tmp_cr2, @tagName(tag)) = v;
                        }
                    },
                }
                switch (options.idle_state_n) {
                    inline else => |v, tag| {
                        if (@hasField(@TypeOf(tmp_cr2), @tagName(tag))) {
                            @field(tmp_cr2, @tagName(tag)) = v;
                        }
                    },
                }
                handle.CR2.write(tmp_cr2);
            }
            switch (options.mode) {
                inline .OC1M, .OC2M => |v, tag| {
                    if (@hasField(@TypeOf(handle.*), "CCMR1_Output")) {
                        var tmp_ccmr1 = handle.CCMR1_Output.read();
                        if (@hasField(@TypeOf(tmp_ccmr1), @tagName(tag))) {
                            const field_name = std.fmt.comptimePrint(
                                "CC{d}S",
                                .{@intCast(u4, @enumToInt(tag)) + 1},
                            );
                            @field(tmp_ccmr1, field_name) = 0;
                            @field(tmp_ccmr1, @tagName(tag)) = @enumToInt(v);
                            handle.CCMR1_Output.write(tmp_ccmr1);
                        }
                    }
                },
                inline .OC3M, .OC4M => |v, tag| {
                    if (@hasField(@TypeOf(handle.*), "CCMR2_Output")) {
                        var tmp_ccmr2 = handle.CCMR2_Output.read();
                        if (@hasField(@TypeOf(tmp_ccmr2), @tagName(tag))) {
                            const field_name = std.fmt.comptimePrint(
                                "CC{d}S",
                                .{@intCast(u4, @enumToInt(tag)) + 1},
                            );
                            @field(tmp_ccmr2, field_name) = 0;
                            @field(tmp_ccmr2, @tagName(tag)) = @enumToInt(v);
                            handle.CCMR2_Output.write(tmp_ccmr2);
                        }
                    }
                },
            }
            switch (options.pulse) {
                inline else => |v, tag| {
                    if (@hasField(@TypeOf(handle.*), @tagName(tag))) {
                        var tmp_ccrx = @field(handle, @tagName(tag));
                        if (@hasField(@TypeOf(tmp_ccrx), @tagName(tag))) {
                            @field(tmp_ccrx, @tagName(tag)) = v;
                            @field(handle, @tagName(tag)).write(tmp_ccrx);
                        }
                    }
                },
            }
            if (@hasField(@TypeOf(handle.*), "CCER")) {
                var tmp_ccer = handle.CCER.read();
                switch (options.output_state) {
                    inline else => |v, tag| {
                        if (@hasField(@TypeOf(tmp_ccer), @tagName(tag))) {
                            @field(tmp_ccer, @tagName(tag)) = v;
                        }
                    },
                }
                switch (options.output_polarity) {
                    inline else => |v, tag| {
                        if (@hasField(@TypeOf(tmp_ccer), @tagName(tag))) {
                            @field(tmp_ccer, @tagName(tag)) = @enumToInt(v);
                        }
                    },
                }
                switch (options.output_n_state) {
                    inline else => |v, tag| {
                        if (@hasField(@TypeOf(tmp_ccer), @tagName(tag))) {
                            @field(tmp_ccer, @tagName(tag)) = v;
                        }
                    },
                }
                switch (options.output_n_polarity) {
                    inline else => |v, tag| {
                        if (@hasField(@TypeOf(tmp_ccer), @tagName(tag))) {
                            @field(tmp_ccer, @tagName(tag)) = @enumToInt(v);
                        }
                    },
                }
                handle.CCER.write(tmp_ccer);
            }
        },
    }
}

pub fn modify(tim: *Tim, comptime name: []const u8, fields: anytype) void {
    switch (tim.handle) {
        inline else => |handle| {
            if (@hasField(@TypeOf(handle.*), name)) {
                var val = @field(handle, name).read();
                inline for (@typeInfo(@TypeOf(fields)).Struct.fields) |field| {
                    if (@hasField(@TypeOf(val), field.name))
                        @field(val, field.name) = @field(fields, field.name);
                }
                @field(handle, name).write(val);
            }
        },
    }
}
