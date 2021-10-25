def _updatesrc_update_test_impl(ctx):
    srcs_len = len(ctx.files.srcs)
    outs_len = len(ctx.files.outs)
    if srcs_len == 0 or outs_len == 0:
        fail("Need to specify srcs and outs.")
    if srcs_len != outs_len:
        fail("""\
The number of srcs does not match the number of outs. \
srcs: {srcs_len}, outs: {outs_len}\
""".format(
            srcs_len = srcs_len,
            outs_len = outs_len,
        ))

    runfiles = ctx.runfiles(files = ctx.files.srcs + ctx.files.outs)

    validate_update_sh = ctx.actions.declare_file(
        ctx.label.name + "_validate_update.sh",
    )
    ctx.actions.write(
        output = validate_update_sh,
        is_executable = True,
        content = """
#!/usr/bin/env bash

set -uo pipefail

# DEBUG BEGIN
set -x
# DEBUG END

assert_different() {
    local src="${1}"
    local out="${2}"
    diff "${src}" "${out}" && \
        echo >&2 "Expected files to differ. src: ${src}, out: ${out}" \
        && return -1
}

assert_same() {
    local src="${1}"
    local out="${2}"
    diff "${src}" "${out}" || \
        echo >&2 "Expected files to be same. src: ${src}, out: ${out}" \
        && return -1
}

# runfiles_dir=$(pwd)
# cd $BUILD_WORKSPACE_DIRECTORY

# Make sure that src and out are different.
""" + "\n".join([
            "assert_different {src} {out}".format(
                src = src.short_path,
                out = ctx.files.outs[idx].short_path,
            )
            for idx, src in enumerate(ctx.files.srcs)
        ]) + """

# Execute the update


# Make sure that src and out are the same.
""" + "\n".join([
            "assert_same {src} {out}".format(
                src = src.short_path,
                out = ctx.files.outs[idx].short_path,
            )
            for idx, src in enumerate(ctx.files.srcs)
        ]),
    )

    return DefaultInfo(executable = validate_update_sh, runfiles = runfiles)

updatesrc_update_test = rule(
    implementation = _updatesrc_update_test_impl,
    attrs = {
        "update_target": attr.label(
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "outs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        # "_validation_script": attr.label(
        #     executable = True,
        #     default = "//scripts:validate_update.sh",
        # ),
    },
    test = True,
)

# def updatesrc_update_test(name, srcs, outs):
#     pass
