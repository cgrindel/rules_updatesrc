load("@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl", "UpdateSrcsInfo")

def _header_impl(ctx):
    outs = []
    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename + "_with_header")
        outs.append(out)
        ctx.actions.run_shell(
            outputs = [out],
            inputs = [src],
            executable = ctx.executable._header_tool,
            arguments = [src.path, out.path, ctx.attr.header],
        )

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
            default = "@simple_example//slow:header.sh",
            executable = True,
            cfg = "host",
            allow_files = True,
        ),
    },
    executable = True,
    doc = "Copies the output files to the workspace directory.",
)
