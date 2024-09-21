#!/bin/bash

repoPath=$1

cd $repoPath

currentBranch=$(git rev-parse --abbrev-ref HEAD)
echo $currentBranch

if [[ $currentBranch != "main" ]]; then
    echo 'git checkout main'
    git checkout main
fi

git pull

version="v$(cat VERSION)"

git tag $version

git push origin main $version