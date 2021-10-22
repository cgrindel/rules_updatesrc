load(":providers.bzl", "UpdateSrcsInfo")

"""A binary rule that copies the formatted Swift sources to the workspace 
directory.
"""

def _updatesrc_update_impl(ctx):
    update_src_depset = depset(
        [],
        transitive = [
            dep[UpdateSrcsInfo].update_srcs
            for dep in ctx.attr.deps
        ],
    )
    update_srcs = update_src_depset.to_list()

    # Make sure that the output files are included in the runfiles.
    runfiles = ctx.runfiles(
        files = [updsrc.out for updsrc in update_srcs],
    )

    update_sh = ctx.actions.declare_file(
        ctx.label.name + "_update_with_formatted.sh",
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
            for updsrc in update_srcs
        ]),
        is_executable = True,
    )

    return DefaultInfo(executable = update_sh, runfiles = runfiles)

updatesrc_update = rule(
    implementation = _updatesrc_update_impl,
    attrs = {
        # "updates": attr.label_keyed_string_dict(
        #     doc = """\
        # A `dict` where the key is the source file\
        # """,
        # ),
        "deps": attr.label_list(
            providers = [[UpdateSrcsInfo]],
            doc = "Build targets that output `UpdateSrcsInfo`.",
        ),
    },
    executable = True,
    doc = "Copies the output files to the workspace directory.",
)
