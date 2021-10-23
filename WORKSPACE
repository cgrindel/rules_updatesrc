workspace(name = "cgrindel_rules_updatesrc")

load("//updatesrc:deps.bzl", "updatesrc_rules_dependencies")

updatesrc_rules_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@cgrindel_bazel_doc//bazeldoc:deps.bzl", "bazeldoc_dependencies")

bazeldoc_dependencies()
