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
            .board = stm32.boards.stm32f103_4wd,
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
