const std = @import("std");
const ckzg = @import("ckzg");

test "trusted setup file can compute and verify a blob proof" {
    var settings = try ckzg.Settings.loadTrustedSetupFile("src/trusted_setup.txt", 0);
    defer settings.deinit();

    const blob = std.mem.zeroes(ckzg.Blob);
    const commitment = try settings.blobToKzgCommitment(&blob);
    const proof = try settings.computeBlobKzgProof(&blob, &commitment);

    try std.testing.expect(try settings.verifyBlobKzgProof(&blob, &commitment, &proof));
}
