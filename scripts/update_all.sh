#!/usr/bin/env bash

# This script will query for all of the updatesrc_update targets and execute
# each one.

set -uo pipefail

cd "${BUILD_WORKSPACE_DIRECTORY}"

bazel_query="kind(updatesrc_update, //...)"
update_targets=( $(bazel query "${bazel_query}" | sort) )

for target in "${update_targets[@]}" ; do
  bazel run "${target}"
done
