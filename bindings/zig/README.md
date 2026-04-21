# Zig Bindings for the C-KZG Library

This directory contains Zig bindings for the C-KZG-4844 library.

## Prerequisites

Use Zig `0.16.0` or greater.

## Build

```sh
zig build -Doptimize=ReleaseSafe
```

## Test

```sh
zig build test
```

## Usage

```zig
const ckzg = @import("ckzg");

var settings = try ckzg.Settings.loadTrustedSetupFile("src/trusted_setup.txt", 0);
defer settings.deinit();
```
