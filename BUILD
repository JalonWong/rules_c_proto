package(default_visibility = ["//visibility:public"])

config_setting(
    name = "msvc",
    flag_values = {"@bazel_tools//tools/cpp:compiler": "msvc-cl"},
)

config_setting(
    name = "no_std",
    define_values = {"protobuf_c_no_std": "true"},
)

config_setting(
    name = "env_protoc",
    define_values = {"protobuf_c_env_protoc": "true"},
)
