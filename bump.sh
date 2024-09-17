#!/bin/bash

#Author: Daan de Jong
#A bash script to increment the (semantic) version number with a minor or patch step.

REPO_PATH="$1"
REPO_NAME=$(basename REPO_PATH)
BUMP_TYPE="$2"
ISSUE="$3"
DESCRIPTION="$4"

cd $REPO_PATH
if [[ ! -f VERSION ]]; then
    echo "Error: VERSION file not found."
    exit 1
elif [[ ! -f CHANGELOG.md ]]; then
    echo "Error: CHANGELOG.md file not found."
    exit 1
fi

LATEST_VERSION_REMOTE=$(git ls-remote --tags origin | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+$' | sort -V | tail -1)
CURRENT_VERSION_LOCAL=$(cat VERSION)

if [[ "$LATEST_VERSION_REMOTE" == "" ]]; then
    echo "Error: No version tags found in the remote repo."
    exit 1
elif [[ "$LATEST_VERSION_REMOTE" != "v$CURRENT_VERSION_LOCAL" ]]; then
    echo "Error: version v$CURRENT_VERSION_LOCAL in VERSION should equal current latest version $LATEST_VERSION_REMOTE."
    exit 1
fi

IFS="." read -r -a VERSION_PARTS <<< "$CURRENT_VERSION_LOCAL"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

case $BUMP_TYPE in
    major)
        ((MAJOR++))
        MINOR=0
        PATCH=0
        ;;
    minor)
        ((MINOR++))
        PATCH=0
        ;;
    patch)
        ((PATCH++))
        ;;
esac

NEW_VERSION=$MAJOR.$MINOR.$PATCH

echo $NEW_VERSION > VERSION

echo "  Bumped version $CURRENT_VERSION_LOCAL --> $NEW_VERSION"
echo "  Updated VERSION file"