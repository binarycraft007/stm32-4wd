const std = @import("std");
const stm32 = @import("deps/stmicro-stm32/build.zig");

// the hardware support package should have microzig as a dependency
const microzig = @import("deps/stmicro-stm32/deps/microzig/build.zig");

pub fn build(b: *std.build.Builder) !void {
    const optimize = b.standardOptimizeOption(.{});
    var exe = microzig.addEmbeddedExecutable(b, .{
        .name = "hello.elf",
        .source_file = .{
            .path = "src/main.zig",
        },
        .backing = .{
            .chip = stm32.chips.stm32f103x8,
        },
        .optimize = optimize,
    });
    exe.installArtifact(b);

    const bin = exe.inner.addObjCopy(.{
        .format = .bin,
        .basename = "hello.bin",
    });
    const bin_install = b.addInstallBinFile(bin.getOutputSource(), bin.basename);
    b.getInstallStep().dependOn(&bin_install.step);
}
