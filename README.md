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
    name = "msg_proto",
    srcs = ["msg.proto"],
)
c_proto_library(
    name = "msg_c_proto",
    deps = [":msg_proto"],
)
cc_binary(
    name = "app",
    deps = [":msg_c_proto"],
)
```

## Build Options
It will download `protoc` and `protoc-gen-c` by default. If you want to use your pre-installed binary, add the following to your `.bazelrc`. You can also use it in the command line.
```sh
build --define=c_proto_env_protoc=true
```

If you don't want to use the heap in the std lib with your source code, for example embedded software, use the following.
```sh
build --define=protobuf_c_no_std=true
```

## Proto Options
If you want to use the options that in the [protobuf-c.proto](https://github.com/protobuf-c/protobuf-c/blob/master/protobuf-c/protobuf-c.proto), add following to your `MODULE.bazel`
```py
...

get_protobuf_c = use_extension("@rules_c_proto//tools:extensions.bzl", "get_protobuf_c")
use_repo(get_protobuf_c, "protobuf_c")
bazel_dep(name = "protobuf", version = "31.1")
```

At your `msg.proto`
```proto
import "protobuf-c/protobuf-c.proto";

// depends on your need
option (pb_c_file).const_strings = true;
option (pb_c_file).use_oneof_field_name = true;
```

`BUILD`
```py
proto_library(
    name = "msg_proto",
    srcs = ["msg.proto"],
    deps = ["@protobuf_c//:protobuf-c_proto"], # add this line
)
```
