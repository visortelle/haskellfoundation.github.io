#!/usr/bin/env bash

# Deploy static site to the GitHub pages.

set -eo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $script_dir/commons.sh

# Monkey patch html files by adding <meta name="robots" content="noindex, nofollow">.
# It will tell search bots like googlebot not to index this content.
search_robots_noindex() {
  # find
}

deploy() {
  if [[ ! -z "$GITHUB_REF_NAME" ]]; then
    # The GITHUB_REF_NAME env variable is available in github actions.
    git_branch=$GITHUB_REF_NAME
  else
    git_branch=$(git branch --show-current)
  fi
  echo "Current git branch is '${git_branch}'."

  git checkout gh-pages
  git pull origin gh-pages

  if [ "$git_branch" == "$main_git_branch" ]; then
    site_dest="${gh_pages_dir}"

    # Create temporary backup for other branches content.
    mv "${deployments_dir}" .

    # Replace site files.
    rm -rf "${site_dest}"
    mkdir -p "${site_dest}"
    cp -a -v ${site_src}/* ${site_dest}/

    # Restore temporary backup for other branches content.
    mv ./branches "${gh_pages_dir}/"
  else
    branch_slug=$(slugify $git_branch)
    site_dest="${gh_pages_dir}/branches/${branch_slug}"

    # Replace site files.
    rm -rf "${site_dest}"
    mkdir -p "${site_dest}"
    cp -a -v ${site_src}/* ${site_dest}/
  fi

  echo "Updating gh-pages branch."
  git add --all
  git commit --allow-empty -m "Update '${git_branch}' branch deployment [ci skip]"
  git push --force origin gh-pages
  echo "Deployment finished."
}

deploy
