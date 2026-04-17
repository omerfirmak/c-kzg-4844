const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const blst = b.dependency("blst", .{});

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
    lib.root_module.link_libc = true;
    lib.root_module.addIncludePath(b.path("src"));
    lib.root_module.addIncludePath(blst.path("bindings"));

    const blst_flags: []const []const u8 = &.{ "-O2", "-ffreestanding", "-D__BLST_PORTABLE__" };
    switch (target.result.cpu.arch) {
        .aarch64, .x86_64 => {
            lib.root_module.addCSourceFiles(.{
                .root = blst.path("."),
                .files = &.{"src/server.c"},
                .flags = blst_flags,
            });
            lib.root_module.addCSourceFiles(.{
                .root = b.path("."),
                .files = &.{"src/ckzg.c"},
                .flags = blst_flags,
            });
            lib.root_module.addAssemblyFile(blst.path("build/assembly.S"));
        },
        else => {
            const no_asm_flags: []const []const u8 = &.{ "-O2", "-ffreestanding", "-D__BLST_PORTABLE__", "-D__BLST_NO_ASM__" };
            lib.root_module.addCSourceFiles(.{
                .root = blst.path("."),
                .files = &.{"src/server.c"},
                .flags = no_asm_flags,
            });
            lib.root_module.addCSourceFiles(.{
                .root = b.path("."),
                .files = &.{"src/ckzg.c"},
                .flags = no_asm_flags,
            });
        },
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

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run Zig binding tests");
    test_step.dependOn(&run_tests.step);
}
