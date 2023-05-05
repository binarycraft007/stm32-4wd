const std = @import("std");
const microzig = @import("deps/microzig/build.zig");

pub const stm32f103x8 = microzig.Chip{
    .name = "STM32F103",
    .source = .{
        .path = "src/chips/STM32F103.zig",
    },
    .cpu = microzig.cpus.cortex_m3,
    .hal = .{ .path = "src/hal.zig" },
    .memory_regions = &.{
        .{
            .offset = 0x08000000,
            .length = 64 * 1024,
            .kind = .flash,
        },
        .{
            .offset = 0x20000000,
            .length = 20 * 1024,
            .kind = .ram,
        },
    },
};

pub fn installBinHex(
    b: *std.build.Builder,
    exe: *std.build.CompileStep,
    comptime name: []const u8,
) void {
    const bin = exe.addObjCopy(.{
        .format = .bin,
        .basename = name ++ ".bin",
    });
    const bin_install = b.addInstallBinFile(
        bin.getOutputSource(),
        bin.basename,
    );
    b.getInstallStep().dependOn(&bin_install.step);

    const hex = exe.addObjCopy(.{
        .format = .hex,
        .basename = name ++ ".hex",
    });
    const hex_install = b.addInstallBinFile(
        hex.getOutputSource(),
        hex.basename,
    );
    b.getInstallStep().dependOn(&hex_install.step);
}

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});
    const blinky = microzig.addEmbeddedExecutable(b, .{
        .name = "blinky.elf",
        .source_file = .{
            .path = "examples/blinky.zig",
        },
        .backing = .{ .chip = stm32f103x8 },
        .optimize = optimize,
    });
    blinky.installArtifact(b);
    installBinHex(b, blinky.inner, "blinky");
}
