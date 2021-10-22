UpdateSrcsInfo = provider(
    doc = """\
Information about files that should be copied from the output to the workspace.\
""",
    fields = {
        "update_srcs": """\
A `depset` of structs as created by `providers.update_src()` which specify the \
source files and their outputs.\
""",
    },
)

def _update_src(src, out):
    """Creates a `struct` specifying a source file and an output file that should be used to update it.

    Args:
        src: A `File` designating a file in the workspace.
        out: A `File` designating a file in the output directory.

    Returns:
        A `struct`.
    """
    return struct(
        src = src,
        out = out,
    )

providers = struct(
    update_src = _update_src,
)
