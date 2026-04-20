const std = @import("std");
const ckzg = @import("ckzg");
const trusted_setup = @import("trusted_setup");

test "embedded trusted setup can compute and verify a blob proof" {
    var settings = try ckzg.Settings.loadTrustedSetup(
        trusted_setup.g1_monomial_bytes,
        trusted_setup.g1_lagrange_bytes,
        trusted_setup.g2_monomial_bytes,
        0,
    );
    defer settings.deinit();

    const blob = std.mem.zeroes(ckzg.Blob);
    const commitment = try settings.blobToKzgCommitment(&blob);
    const proof = try settings.computeBlobKzgProof(&blob, &commitment);

    try std.testing.expect(try settings.verifyBlobKzgProof(&blob, &commitment, &proof));
}

test "trusted setup point counts match expected mainnet values" {
    try std.testing.expectEqual(@as(usize, 4096), trusted_setup.num_g1_points);
    try std.testing.expectEqual(@as(usize, 65), trusted_setup.num_g2_points);
    try std.testing.expectEqual(trusted_setup.num_g1_points * 48, trusted_setup.g1_lagrange_bytes.len);
    try std.testing.expectEqual(trusted_setup.num_g1_points * 48, trusted_setup.g1_monomial_bytes.len);
    try std.testing.expectEqual(trusted_setup.num_g2_points * 96, trusted_setup.g2_monomial_bytes.len);
}
