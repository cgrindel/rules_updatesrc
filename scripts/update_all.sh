#!/usr/bin/env bash

# This script will query for all of the updatesrc_update targets and execute
# each one.

set -uo pipefail

cd "${BUILD_WORKSPACE_DIRECTORY}"

# rules_to_run=("${@}")

# targets_to_run=()
# for rule in rules_to_run ; do
#   bazel_query="kind(${rule}, //...)"
#   targets_to_run+=( $(bazel query "${bazel_query}" | sort) )
# done

# Collect targets that have been specified on the command-line
targets_to_run=("${@:-}")

# Query for any 'updatesrc_update' targets
bazel_query="kind(updatesrc_update, //...)"
targets_to_run+=( $(bazel query "${bazel_query}" | sort) )

for target in "${targets_to_run[@]}" ; do
  if [[ -z "${target:-}" ]]; then
    continue
  fi
  bazel run "${target}"
done
