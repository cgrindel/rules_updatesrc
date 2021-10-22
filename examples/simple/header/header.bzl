load("@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl", "UpdateSrcsInfo", "providers")

def _header_impl(ctx):
    outs = []
    update_srcs = []
    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename + "_with_header")
        outs.append(out)
        update_srcs.append(providers.update_src(src = src, out = out))
        ctx.actions.run(
            outputs = [out],
            inputs = [src],
            executable = ctx.executable._header_tool,
            arguments = [src.path, out.path, ctx.attr.header],
        )

    return [
        DefaultInfo(files = depset(outs)),
        UpdateSrcsInfo(update_srcs = depset(update_srcs)),
    ]

header = rule(
    implementation = _header_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "header": attr.string(
            mandatory = True,
        ),
        "_header_tool": attr.label(
            default = "@simple_example//header:header.sh",
            executable = True,
            cfg = "host",
            allow_files = True,
        ),
    },
    doc = "Copies the output files to the workspace directory.",
)
