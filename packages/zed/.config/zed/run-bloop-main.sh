#!/bin/bash

project_name=$(basename $1) # Extract the project name from the $ZED_WORKTREE_ROOT
filepath=$2
mainname=$3

package_name=$(cat $filepath | grep -E '^package ' | sed 's/package //') # Extract the package name from the main file

bloop run $project_name -m "$package_name.$mainname"
