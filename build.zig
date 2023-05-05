const std = @import("std");
const microzig = @import("deps/microzig/build.zig");

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});
    const exe = microzig.addEmbeddedExecutable(b, .{
        .name = "hello.elf",
        .source_file = .{
            .path = "src/main.zig",
        },
        .backing = .{
            .chip = microzig.Chip{
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
            },
        },
        .optimize = optimize,
    });
    exe.installArtifact(b);

    const bin = exe.inner.addObjCopy(.{
        .format = .bin,
        .basename = "hello.bin",
    });
    const bin_install = b.addInstallBinFile(
        bin.getOutputSource(),
        bin.basename,
    );
    b.getInstallStep().dependOn(&bin_install.step);

    const hex = exe.inner.addObjCopy(.{
        .format = .hex,
        .basename = "hello.hex",
    });
    const hex_install = b.addInstallBinFile(
        hex.getOutputSource(),
        hex.basename,
    );
    b.getInstallStep().dependOn(&hex_install.step);
}
