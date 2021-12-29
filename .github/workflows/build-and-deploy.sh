#!/usr/bin/env bash

set -exo pipefail

git_repo_root=$(git rev-parse --show-toplevel)

# replace "/", "#", etc with "-".
slugify() {
  echo "$1" | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+/-/g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$/-/g' | tr A-Z a-z
}
git_branch=$(slugify $(git rev-parse --abbrev-ref HEAD))
echo "Current git branch is '${git_branch}'"

git config user.name github-actions
git config user.email github-actions@github.com

stack build --system-ghc
stack exec --system-ghc site build

site_src="${git_repo_root}/_site"
site_dest="${git_repo_root}/branches/${git_branch}"

git checkout gh-pages
git pull origin gh-pages

# Overwrite existing files with new files
rm -rf "${site_dest}"
mkdir -p "${site_dest}"
cp -a -v ${site_src}/* "${site_dest}/"
cp -a -v ${site_src}/.* "${site_dest}/"

git add --all
git commit --allow-empty -m "[$(date '+%F %T %Z')] Updated site for the '${git_branch}' branch [ci skip]"
git push --force origin gh-pages

echo "Deployment finished"
