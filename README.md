# Update Source File Rules for Bazel

[![Build](https://github.com/cgrindel/rules_updatesrc/actions/workflows/bazel.yml/badge.svg)](https://github.com/cgrindel/rules_updatesrc/actions/workflows/bazel.yml)

This repository contains [Bazel](https://bazel.build/) rules and macros that copy files from the
Bazel output directories to the workspace directory.

Have you ever wanted to copy the output of a Bazel build step to your source directory (e.g.,
generated documentation, formatted source files)? Instead of recreating the logic to perform this
trick in every Bazel project, I consolidated the logic here in this repository.

## Quickstart

The following provides a quick introduction on how to use the rules in this repository. Also, check
out [the documentation](/doc/) and [the examples](/examples/) for more information.

### 1. Configure your workspace to use `rules_swiftformat`

Add the following to your `WORKSPACE` file to add this repository and its dependencies.

```python

# TODO: FIX ME!
local_repository(
    name = "cgrindel_rules_updatesrc",
    path = "../rules_updatesrc"
)

load(
    "@cgrindel_rules_updatesrc//updatesrc:deps.bzl",
    "updatesrc_rules_dependencies",
)

updatesrc_rules_dependencies()
```

### 2. Update the `BUILD.bazel` at the root of your workspace

At the root of your workspace, create a `BUILD.bazel` file, if you don't have one. Add the
following:

```python
load(
    "@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl",
    "updatesrc_update_all",
)

# Define a runnable target to execute all of the updatesrc_update targets
# that are defined in your workspace.
updatesrc_update_all(
    name = "update_all",
)
```

### 3. Add `updatesrc_update` to every Bazel package that has files to copy

In every Bazel package that contains source files that should be updated from build output, add a
[updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) declaration. For more
information on how to configure the declaration check out the [documentation](/doc) and the
[examples](/examples).

```python
load(
    "@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl",
    "updatesrc_update",
)

updatesrc_update(
    name = "update",
    # ...
)
```

### 4. Execute the Update All Target

To execute all of the [updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update)
targets, run the update all target at the root of your workspace.

```sh
$ bazel run //:update_all
```




## What Can These Rules Do?

For more detailed information, check out the [examples](/examples) and the [documentation](/doc).

### `updatesrc_update`: Rule to Copy Files to the Workspace Directory

The [updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) rule defines an
executable Bazel target that will copy specified files from the output to the workspace/source
directory. There are two ways to specify files to copy. 

#### Option #1: Specify the Files Using the `srcs` and `outs` Attributes

This option is useful if you are generating files with a
[genrule](https://docs.bazel.build/versions/main/be/general.html#genrule) or something similar. In
the same Bazel package as the the `genrule`, you define a
[updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) target specifying the source
files using the `srcs` attribute and the output files using the `outs` attribute. The sr

In the following example, the `genrule` targets accept a source file (e.g., `c.txt`) and create a
modified version of the source file (e.g., `c.txt_modified`). The
[updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) target accepts a list of the
source files and a list of the output files. The source list and output list must evaluate to file
lists that have the same length, as the contents of the n-th index of the output list replaces the
contents of the n-th index of the source list.

```python
load(
    "@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl",
    "updatesrc_update",
)

genrule(
    name = "c_modified",
    srcs = ["c.txt"],
    outs = ["c.txt_modified"],
    cmd = """\
echo "# Howdy" > $@
cat $(location c.txt) >> $@
""",
)

genrule(
    name = "d_modified",
    srcs = ["d.txt"],
    outs = ["d.txt_modified"],
    cmd = """\
echo "# Howdy" > $@
cat $(location d.txt) >> $@
""",
)

updatesrc_update(
    name = "update",
    srcs = ["c.txt", "d.txt"],
    outs = [":c_modified", ":d_modified"],
)
```

To copy the output files to the source directory, you need to execute the
[updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) target.

```sh
$ bazel run //path/to/pkg:update
```

#### Option #2: Custom Rule Provides `UpdateSrcsInfo`

The second option is for Bazel rule authors. This repository defines a provider called
[UpdateSrcsInfo](/doc/providers_overview.md#UpdateSrcsInfo). If a rule generates an output that can
be copied to the source directory, the rule can provide an instance of this provider along with its
other providers. The instance defines the mapping of the source files and their corresponding output
files.

In the following example, we define a rule called `header`. It adds header text to the top of a
source file. In addition to returning a `DefaultInfo` provider, it returns an instance of an
`UpdateSrcsInfo` provider with the a mapping between the source files and the output files.

```python
load(
    "@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl",
    "UpdateSrcsInfo",
    "update_srcs",
)

def _header_impl(ctx):
    outs = []
    updsrcs = []
    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename + "_with_header")
        outs.append(out)
        updsrcs.append(update_srcs.create(src = src, out = out))
        ctx.actions.run(
            outputs = [out],
            inputs = [src],
            executable = ctx.executable._header_tool,
            arguments = [src.path, out.path, ctx.attr.header],
        )

    return [
        DefaultInfo(files = depset(outs)),
        UpdateSrcsInfo(update_srcs = depset(updsrcs)),
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
```

A Bazel package that uses the rule looks like the following:

```python
load("//header:header.bzl", "header")
load("@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl", "updatesrc_update")

header(
    name = "add_headers",
    srcs = glob(["*.txt"]),
    header = "# Super cool header",
)

updatesrc_update(
    name = "update",
    deps = [":add_headers"],
)
```

To copy the output files to the source directory, you need to execute the
[updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) target.

```sh
$ bazel run //path/to/pkg:update
```

### `updatesrc_update_all`: Macro to Execute All of Your `updatesrc_update` Targets

Once you start using [updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) rule,
you will want an easy way to copy all of your updatable files to your source directory. Enter the
[updatesrc_update_all](/doc/rules_and_macros_overview.md#updatesrc_update_all) macro.

Simply define an [updatesrc_update_all](/doc/rules_and_macros_overview.md#updatesrc_update_all)
target in a convenient location in your Bazel project (e.g., the root), then execute the target.
When the target is executed, it will query your project for all instances of
[updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) and execute them one at a
time.

For instance, create an
[updatesrc_update_all](/doc/rules_and_macros_overview.md#updatesrc_update_all) target at the root of
your Bazel workspace.

```python
load(
    "@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl",
    "updatesrc_update_all",
)

updatesrc_update_all(
    name = "update_all",
)
```

Then, to update all of your source files, execute the `update_all` target.

```sh
$ bazel run //:update_all
```

In addition to executing all of the
[updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) targets automatically, the
[updatesrc_update_all](/doc/rules_and_macros_overview.md#updatesrc_update_all) macro can be
configured to run any other executable target. This is handy if you ended up writing your own file
copy script, but would like to have everything update with a simple command.

In this example, we defined an `update_all` target that executes all of the
[updatesrc_update](/doc/rules_and_macros_overview.md#updatesrc_update) targets and executes a custom
target called `//doc:update`.

```python
load(
    "@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl",
    "updatesrc_update_all",
)

updatesrc_update_all(
    name = "update_all",
    targets_to_run = [
        "//doc:update",
    ],
)
```
