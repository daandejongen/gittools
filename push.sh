#!/bin/bash -e

BLUE='\033[0;34m'
NO_COLOR='\033[0m'

REPO_PATH=$1
ISSUE_NUMBER=$2
DESCRIPTION="$3"

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

cd $REPO_PATH

if [[ ! -f VERSION ]]; then
    echo "Error: VERSION file not found."
    exit 1
elif [[ ! -f CHANGELOG.md ]]; then
    echo "Error: CHANGELOG.md file not found."
    exit 1
fi

LATEST_VERSION_REMOTE=$(git ls-remote --tags origin | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+$' | sort -V | tail -1)
VERSION_LOCAL=$(cat VERSION)

if [[ "$LATEST_VERSION_REMOTE" == "" ]]; then
    echo "Error: No version tags found in the remote repo."
    exit 1
elif [[ $LATEST_VERSION_REMOTE == $VERSION_LOCAL ]]; then
    echo "Error: update version before committing, run: bump [minor|patch] <title>"
    exit 1
elif [[ "$GIT_BRANCH" == "main" ]]; then
    echo "Error: make sure to push from a feature branch"
    exit 1
fi

COMMIT_MESSAGE="#${ISSUE} | $VERSION_LOCAL | $DESCRIPTION"

echo -e "\n${BLUE}git add .${NO_COLOR}\n"
git add .

echo -e "\n${BLUE}git commit -m '$COMMIT_MESSAGE'${NO_COLOR}\n"
git commit -m "$COMMIT_MESSAGE"

echo -e "\n${BLUE}git push --set-upstream origin $GIT_BRANCH${NO_COLOR}\n"
git push --set-upstream origin "$GIT_BRANCH"

echo -e "\n${BLUE}git checkout main${NO_COLOR}\n"
git checkout main

echo -e "\n${BLUE}git branch -d $GIT_BRANCH${NO_COLOR}\n"
git branch -d "$GIT_BRANCH" >/dev/null 2>&1

echo "opening pull request..."
sleep 3
open "https://github.com/daandejongen/$(basename $PWD)/pull/new/$GIT_BRANCH"