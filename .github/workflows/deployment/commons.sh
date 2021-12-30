#!/usr/bin/env bash

export repo_root_dir=$(git rev-parse --show-toplevel)
export site_src="${repo_root_dir}/_site"
export gh_pages_dir="${repo_root_dir}/docs"
export deployments_dir="${gh_pages_dir}/branches"

# Site built from the main branch will be available at 'https://<domain_name>/'.
# Sites built from other branchs will be available at 'https://<domain_name>/branches/<branch_name>'.
export main_git_branch="hakyll"

# replace "/", "#", etc with "-".
slugify() {
  echo "$1" | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+/-/g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$/-/g' | tr A-Z a-z
}
export -f slugify
