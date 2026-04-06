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
    addCkzgSources(lib, b);
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

fn addCkzgSources(step: *std.Build.Step.Compile, b: *std.Build) void {
    step.linkLibC();
    step.addIncludePath(b.path("src"));
    step.addCSourceFiles(.{
        .root = b.path("."),
        .files = &.{
            "src/ckzg.c",
        },
        .flags = &.{
            "-O2",
            "-fno-builtin",
        },
    });
}
