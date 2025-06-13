load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//tools:tools_reg.bzl", "PROTOC", "PROTOC_C")

def get_os_key(ctx):
    if "windows" in ctx.os.name:
        key = "windows"
    elif "mac" in ctx.os.name:
        key = "macos"
    else:
        key = ctx.os.name

    if ctx.os.arch == "x86_64":
        return key + "-amd64"
    else:
        return key + "-" + ctx.os.arch

def _get_protoc_impl(ctx):
    p = PROTOC[0][get_os_key(ctx)]
    http_archive(
        name = "get_protoc_",
        url = p["url"],
        sha256 = p["sha256"],
        build_file = "//:tools/bin.BUILD",
    )

get_protoc = module_extension(
    implementation = _get_protoc_impl,
)

def _get_protoc_c_impl(ctx):
    p = PROTOC_C[0][get_os_key(ctx)]
    http_archive(
        name = "get_protoc_c_",
        url = p["url"],
        sha256 = p["sha256"],
        build_file = "//:tools/bin.BUILD",
    )

get_protoc_c = module_extension(
    implementation = _get_protoc_c_impl,
)
