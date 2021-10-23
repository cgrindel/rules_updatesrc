load(":providers.bzl", "UpdateSrcsInfo")
load(":update_srcs.bzl", "update_srcs")

"""A binary rule that copies the formatted Swift sources to the workspace 
directory.
"""

def _updatesrc_update_impl(ctx):
    srcs_len = len(ctx.files.srcs)
    outs_len = len(ctx.files.outs)
    if srcs_len != outs_len:
        fail("""\
The number of srcs does not match the number of outs. \
srcs: {srcs_len}, outs: {outs_len}\
""".format(
            srcs_len = srcs_len,
            outs_len = outs_len,
        ))

    updsrcs = []
    for idx, src in enumerate(ctx.files.srcs):
        out = ctx.files.outs[idx]
        updsrcs.append(update_srcs.create(src = src, out = out))

    update_src_depset = depset(
        # [update_srcs.from_json(json_str) for json_str in ctx.attr.update_srcs],
        updsrcs,
        transitive = [
            dep[UpdateSrcsInfo].update_srcs
            for dep in ctx.attr.deps
        ],
    )
    all_updsrcs = update_src_depset.to_list()

    # Make sure that the output files are included in the runfiles.
    runfiles = ctx.runfiles(files = [updsrc.out for updsrc in all_updsrcs])

    update_sh = ctx.actions.declare_file(
        ctx.label.name + "_update.sh",
    )
    ctx.actions.write(
        output = update_sh,
        content = """
#!/usr/bin/env bash
runfiles_dir=$(pwd)
cd $BUILD_WORKSPACE_DIRECTORY
""" + "\n".join([
            "cp -f $(readlink \"${{runfiles_dir}}/{out}\") {src}".format(
                src = updsrc.src.short_path,
                out = updsrc.out.short_path,
            )
            for updsrc in all_updsrcs
        ]),
        is_executable = True,
    )

    return DefaultInfo(executable = update_sh, runfiles = runfiles)

updatesrc_update = rule(
    implementation = _updatesrc_update_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "outs": attr.label_list(
            allow_files = True,
        ),
        "deps": attr.label_list(
            providers = [[UpdateSrcsInfo]],
            doc = "Build targets that output `UpdateSrcsInfo`.",
        ),
    },
    executable = True,
    doc = "Copies the output files to the workspace directory.",
)
