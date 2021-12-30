#!/usr/bin/env bash

# Deploy static site to the GitHub pages.

set -eo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $script_dir/commons.sh

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

  remote_branches=$(git ls-remote --heads origin | sed 's?.*refs/heads/??' | grep -v "gh-pages" | grep -v "${main_git_branch}")
  echo "$remote_branches" | while IFS= read -r branch; do
    branch_slug=$(slugify $branch)
    deployment_url="https://${github_repo_owner}.github.io/${github_repo_name}/branches/${branch_slug}"
    echo "| [${branch}](https://github.com/${github_repo_owner}/${github_repo_name}/tree/${branch}) | [Open](${deployment_url}) |" >>$deployments_list
  done

  # Update gh-pages branch
  git add --all
  git commit --allow-empty -m "Update ${deployments_list} [ci skip]"
  git push --force origin gh-pages
}

deploy
update_deployments_list