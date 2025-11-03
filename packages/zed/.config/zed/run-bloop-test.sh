#!/bin/bash

project_name=$(basename $1) # Extract the project name from the $ZED_WORKTREE_ROOT
filename=$2

bloop test $project_name -o "*$filename*"
