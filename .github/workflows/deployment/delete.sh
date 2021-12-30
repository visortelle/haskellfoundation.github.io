#!/usr/bin/env bash

# Remove deployment by specified git branch name.
# Script assumes that you are on gh-pages branch.

set -eo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $script_dir/commons.sh

branch_slug=$($script_dir/slugify.sh $1)

rm -rf "$deployments_dir/$branch_slug"
