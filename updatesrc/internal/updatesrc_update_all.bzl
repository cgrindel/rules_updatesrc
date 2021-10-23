"""A macro that defines a runnable target that will copy all of the formatted 
Swift source files to the workspace directory.
"""

def updatesrc_update_all(name):
    """Defines a runnable target that will copy the formatted Swift files to the source tree.

    The utility queries for all of the updatesrc_update rules in the
    workspace and executes each one. Hence, only Swift source files that are
    referenced by a updatesrc_update will be copied to the workspace
    directory.

    Args:
        name: The name of the target.

    Returns:
        None.
    """
    native.sh_binary(
        name = name,
        srcs = [
            "@cgrindel_rules_updatesrc//scripts:update_all.sh",
        ],
    )
