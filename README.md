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


