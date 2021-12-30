#!/usr/bin/env bash

# Updates deployments markdown table.

set -eo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $script_dir/commons.sh

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
