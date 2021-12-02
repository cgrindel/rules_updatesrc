load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def updatesrc_rules_dependencies():
    """Loads the dependencies for `rules_updatesrc`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_doc",
        sha256 = "bae4a0f41cc5cf89f26c779fc04379f09bb290b4910b2cf206c0372ad0c8aac7",
        strip_prefix = "bazel-doc-0.1.0",
        urls = ["https://github.com/cgrindel/bazel-doc/archive/v0.1.0.tar.gz"],
    )

    maybe(
        http_archive,
        name = "cgrindel_rules_bzlformat",
        sha256 = "b45b392613092b42c4ee94051be104b990e3c8651dea17410dfd63b98957cd57",
        strip_prefix = "rules_bzlformat-0.1.0",
        urls = ["https://github.com/cgrindel/rules_bzlformat/archive/v0.1.0.tar.gz"],
    )

    # TODO: FIX ME

    # maybe(
    #     http_archive,
    #     name = "cgrindel_rules_bazel_integration_test",
    #     sha256 = "4fa679d98318df3e280e9c8b7f445cd06de7954aa0454702a62ebab8c820ce7e",
    #     strip_prefix = "rules_bazel_integration_test-0.1.0",
    #     urls = ["https://github.com/cgrindel/rules_bazel_integration_test/archive/v0.1.0.tar.gz"],
    # )

    maybe(
        native.local_repository,
        name = "cgrindel_rules_bazel_integration_test",
        path = "/Users/chuck/code/cgrindel/rules_bazel_integration_test",
    )
