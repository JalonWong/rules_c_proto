load("@rules_c_proto//:base.bzl", "c_proto_library")

package(default_visibility = ["//visibility:public"])

proto_library(
    name = "test_proto",
    srcs = ["test.proto"],
)
c_proto_library(
    name = "test_c_proto",
    deps = [":test_proto"],
)
cc_test(
    name = "test",
    srcs = ["test.cc"],
    deps = [
        ":test_c_proto",
        "@googletest//:gtest_main",
    ],
)
