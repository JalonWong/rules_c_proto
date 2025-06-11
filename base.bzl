""" Generate protobuf C code """

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")

def cc_library_func(ctx, name, hdrs, srcs, copts, dep_ccinfos, includes = []):
    compilation_contexts = [info.compilation_context for info in dep_ccinfos]
    linking_contexts = [info.linking_context for info in dep_ccinfos]
    toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    (compilation_context, compilation_outputs) = cc_common.compile(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = toolchain,
        name = name,
        srcs = srcs,
        includes = includes,
        public_hdrs = hdrs,
        user_compile_flags = copts,
        compilation_contexts = compilation_contexts,
    )

    # buildifier: disable=unused-variable
    (linking_context, linking_outputs) = cc_common.create_linking_context_from_compilation_outputs(
        actions = ctx.actions,
        name = name,
        feature_configuration = feature_configuration,
        cc_toolchain = toolchain,
        compilation_outputs = compilation_outputs,
        linking_contexts = linking_contexts,
        disallow_dynamic_library = cc_common.is_enabled(feature_configuration = feature_configuration, feature_name = "targets_windows") or not cc_common.is_enabled(feature_configuration = feature_configuration, feature_name = "supports_dynamic_linker"),
    )

    return CcInfo(
        compilation_context = compilation_context,
        linking_context = linking_context,
    )

def _impl(ctx):
    if ctx.executable.protoc:
        protoc = ctx.executable.protoc
    else:
        protoc = "protoc"

    proto = ctx.attr.deps[0][ProtoInfo]

    proto_files = proto.direct_sources
    output_dir = ctx.genfiles_dir.path

    outputs = []
    for proto_file in proto_files:
        base_name = proto_file.basename[:-6]  # remove .proto suffix
        hdr = ctx.actions.declare_file(base_name + ".pb-c.h")
        outputs.append(hdr)
        src = ctx.actions.declare_file(base_name + ".pb-c.c")
        outputs.append(src)

    args = ctx.actions.args()
    args.add("--c_out=" + output_dir)
    args.add_all(["-I" + p for p in proto.transitive_proto_path.to_list()])
    args.add_all([proto_file.path for proto_file in proto_files])
    # print(args)

    ctx.actions.run(
        inputs = proto_files,
        outputs = outputs,
        executable = protoc,
        arguments = [args],
        mnemonic = "ProtoCompile",
        progress_message = "Generating C proto files for %s" % ctx.label,
        use_default_shell_env = True,
    )

    copts = []
    if ctx.var.get("C_COMPILER", "") == "msvc-cl":
        copts.append("/utf-8")

    return cc_library_func(
        ctx = ctx,
        name = ctx.label.name,
        hdrs = [hdr],
        srcs = [src],
        copts = copts,
        dep_ccinfos = [ctx.attr._dep[CcInfo]],
        includes = [output_dir],
    )

_c_proto = rule(
    implementation = _impl,
    attrs = {
        "deps": attr.label_list(
            mandatory = True,
            providers = [ProtoInfo],
        ),
        "protoc": attr.label(
            executable = True,
            cfg = "exec",
        ),
        "_dep": attr.label(
            default = "@rules_c_proto//src:protobuf_c",
        ),
    },
    toolchains = use_cpp_toolchain(),
    fragments=["cpp"],
    provides = [CcInfo],
)

def c_proto_library(name, deps = []):
    _c_proto(
        name = name,
        deps = deps,
        protoc = select({
            "@rules_c_proto//:env_protoc": None,
            "//conditions:default": "@protobuf//:protoc",
        }),
    )
