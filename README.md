# Protobuf-C rules for Bazel

The C source code comes from [protobuf-c](https://github.com/protobuf-c/protobuf-c)

protobuf-c version: 1.5.2

## Getting Started
First, install `proto-gen-c`. And add the path to environment variable `PATH`.

`MODULE.bazel`
```py
bazel_dep(name = "rules_c_proto")
git_override(
    module_name="rules_c_proto",
    remote="https://github.com/JalonWong/rules_c_proto.git",
    branch="main",
)
```

`BUILD`
```py
load("@rules_c_proto//:base.bzl", "c_proto_library")

proto_library(
    name = "test_proto",
    srcs = ["test.proto"],
)
c_proto_library(
    name = "test_c_proto",
    deps = [":test_proto"],
)
cc_binary(
    name = "app",
    deps = [":test_c_proto"],
)
```

### Options
It will compile `protoc` by default. If you want to use your pre-installed `protoc`, add the following to your `.bazelrc`. You can also use it in the command line.
```sh
build --define=protobuf_c_env_protoc=true
```

If you don't want to use the heap in the std lib, for example embedded software, use the following.
```sh
build --define=protobuf_c_no_std=true
```
