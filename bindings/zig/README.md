# Zig Bindings for the C-KZG Library

This directory contains Zig bindings for the C-KZG-4844 library.

## Prerequisites

Use Zig `0.16.0` or greater.

## Build

```sh
zig build -Doptimize=ReleaseSafe
```

## Test

Convert tests from YAML to JSON (requires [`yq`](https://github.com/mikefarah/yq)):

```sh
find tests -name "data.yaml" -exec sh -c 'yq -o=json "$1" > "$(dirname "$1")/data.json"' _ {} \;
```

Then run:

```sh
zig build test
```

## Usage

```zig
const ckzg = @import("ckzg");

var settings = try ckzg.Settings.loadTrustedSetupFile("src/trusted_setup.txt", 0);
defer settings.deinit();
```
