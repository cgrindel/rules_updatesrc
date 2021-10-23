load(":providers.bzl", "UpdateSrcsInfo")
load(":update_srcs.bzl", "update_srcs")

def _update_src_impl(ctx):
    update_src = update_srcs.create(src = ctx.file.src, out = ctx.file.out)
    return [
        UpdateSrcsInfo(update_srcs = depset([update_src])),
    ]

update_src = rule(
    implementation = _update_src_impl,
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "out": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
    },
    doc = "Outputs a `UpdateSrcsInfo`.",
)
