const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ckzg_module = b.addModule("ckzg", .{
        .root_source_file = b.path("bindings/zig/src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    ckzg_module.addIncludePath(b.path("src"));

    const lib = b.addLibrary(.{
        .name = "ckzg",
        .linkage = .static,
        .root_module = ckzg_module,
    });
    lib.linkLibC();
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(b.path("blst/bindings"));
    switch (target.result.cpu.arch) {
        .aarch64, .x86_64 => {
            lib.addCSourceFiles(.{
                .root = b.path("."),
                .files = &.{ "blst/src/server.c", "src/ckzg.c" },
                .flags = &.{ "-O2", "-ffreestanding", "-D__BLST_PORTABLE__" },
            });
            lib.addAssemblyFile(b.path("blst/build/assembly.S"));
        },
        else => lib.addCSourceFiles(.{
            .root = b.path("."),
            .files = &.{ "blst/src/server.c", "src/ckzg.c" },
            .flags = &.{ "-O2", "-ffreestanding", "-D__BLST_PORTABLE__", "-D__BLST_NO_ASM__" },
        }),
    }

    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("bindings/zig/src/tests.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{ .name = "ckzg", .module = ckzg_module },
            },
        }),
    });
    tests.linkLibrary(lib);

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run Zig binding tests");
    test_step.dependOn(&run_tests.step);
}
