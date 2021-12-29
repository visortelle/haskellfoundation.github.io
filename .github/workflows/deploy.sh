#!/usr/bin/env bash

# Deploy static site to the GitHub pages.

set -eo pipefail

git_repo_root=$(git rev-parse --show-toplevel)
site_src="${git_repo_root}/_site"
gh_pages_root="${git_repo_root}/docs"

# Site built from the main branch will be available at 'https://<domain_name>/'.
# Sites built from other branchs will be available at 'https://<domain_name>/branches/<branch_name>'.
main_git_branch="hakyll"

# replace "/", "#", etc with "-".
slugify() {
  echo "$1" | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+/-/g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$/-/g' | tr A-Z a-z
}

deploy() {
  if [[ ! -z "$GITHUB_REF_NAME" ]]; then
    # The GITHUB_REF_NAME env variable is available in github actions.
    git_branch=$GITHUB_REF_NAME
  else
    git_branch=$(git branch --show-current)
  fi
  echo "Current git branch is '${git_branch}'."

  git config user.name github-actions
  git config user.email github-actions@github.com

  git checkout gh-pages
  git pull origin gh-pages

  if [ "$git_branch" == "$main_git_branch" ]; then
    site_dest="${gh_pages_root}"

    # Create temporary backup for other branches content.
    mv "${gh_pages_root}/branches" .

    # Replace site files.
    rm -rf "${site_dest}"
    mkdir -p "${site_dest}"
    cp -a -v ${site_src}/* ${site_dest}/

    # Restore temporary backup for other branches content.
    mv ./branches "${gh_pages_root}/"
  else
    site_dest="${gh_pages_root}/branches/$(slugify ${git_branch})"

    # Replace site files.
    rm -rf "${site_dest}"
    mkdir -p "${site_dest}"
    cp -a -v ${site_src}/* ${site_dest}/
  fi

  echo "Updating gh-pages branch."
  git add --all
  git commit --allow-empty -m "[$(date '+%F %T %Z')] Updated site for the '${git_branch}' branch [ci skip]"
  git push --force origin gh-pages
  echo "Deployment finished."
}

update_deployments_list() {
  github_project_url=$(git remote get-url origin)
  if [[ $github_project_url == git@github.com:* ]]; then
    github_repo=$(echo ${github_project_url#"git@github.com:"} | sed 's/\.git$//g')
  elif [[ $github_project_url == https://github.com/* ]]; then
    github_repo=$(echo ${github_project_url#"https://github.com/"} | sed 's/\.git$//g' | sed 's/^\/\///g')
  fi

  github_repo_owner=$(echo "${github_repo}" | sed 's/\/.*$//g')
  github_repo_name=$(echo "${github_repo}" | sed 's/^.*\///g')

  deployments_list="DEPLOYMENTS.md"
  echo "Updating ${deployments_list}"
  rm $deployments_list

  # Create a markdown table
  touch $deployments_list
  echo "# Deployments" >>$deployments_list
  echo "" >>$deployments_list
  echo "| Branch | Link |" >>$deployments_list
  echo "| --- | --- |" >>$deployments_list

  main_deployment_url="https://${github_repo_owner}.github.io/${github_repo_name}/"
  echo "| [${main_git_branch}](https://github.com/${github_repo_owner}/${github_repo_name}/tree/${branch}) | [Open](${main_deployment_url}) |" >>$deployments_list

  remote_branches=$( git ls-remote --heads origin | sed 's?.*refs/heads/??' | grep -v "gh-pages" | grep -v "${main_git_branch}")
  echo "$remote_branches" | while IFS= read -r branch; do
    safe_branch=$(slugify $branch)
    deployment_url="https://${github_repo_owner}.github.io/${github_repo_name}/branches/${safe_branch}"
    echo "| [${branch}](https://github.com/${github_repo_owner}/${github_repo_name}/tree/${branch}) | [Open](${deployment_url}) |" >>$deployments_list
  done

  # Update gh-pages branch
  git add --all
  git commit --allow-empty -m "Update ${deployments_list}"
  git push --force origin gh-pages
}

deploy
update_deployments_list
