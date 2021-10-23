def _create(src, out):
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

# def _to_json(src, out):
#     update_src = _update_src(src, out)
#     return json.encode(update_src)

# def _from_json(json_str):
#     return json.decode(json_str)

update_srcs = struct(
    create = _create,
    # to_json = _to_json,
    # from_json = _from_json,
)
