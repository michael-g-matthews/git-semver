#!/usr/bin/env bash

gitversion_image="gittools/gitversion:6.5.1"

get_version() {
    local gitdir
    local version
    local branch
    gitdir="$(pwd)"
    version="$(docker run --rm -v "${gitdir}:/repo" "${gitversion_image}" /repo /showVariable FullSemVer)"
    branch="$(git rev-parse --abbrev-ref HEAD)"
    echo "(${branch}) ${version}"
    git log --oneline --graph --decorate --all
}

get_mmp() {
    local gitdir
    gitdir="$(pwd)"
    docker run --rm -v "${gitdir}:/repo" "${gitversion_image}" /repo /showVariable MajorMinorPatch
}

merge_commit() {
    local source
    local target
    source=$1
    target=$2
    git merge --no-ff -m "Merge '$source' into '$target'" "${source}"
}

################################################################################
# Git init
echo "=== GitVersion.yml ==="
cat GitVersion.yml
echo "=== Creating Repository ==="
git init
echo "*.log" > .gitignore
git add .
git commit -m "Initial Commit"
get_version
git checkout -b dev
get_version

echo "=== GitVersion.yml as read by GitVersion ==="
docker run --rm -v "$(pwd):/repo" "${gitversion_image}" /repo /showConfig

################################################################################
## Feature Development

echo "=== Feature Development ==="

feature_key="FOO-1"
feature_branch="${feature_key}-add-feature"
git checkout -b "${feature_branch}"
get_version
echo "Adding new feature ..." > "${feature_key}"
git add .
git commit -m "feat(${feature_key}): Added a new feature"
get_version
# Merge Request
echo "Open merge request..."
mr_one="merge-requests/1/merge"
git checkout -b "$mr_one" dev
git merge "${feature_branch}"
get_version

git checkout dev
echo "Merge request approved..."
merge_commit "$feature_branch" dev
get_version

################################################################################
# Release Procedure

echo "=== Release Procedure ==="

release_version="0.1.0"
release_branch="release/${release_version}"
git checkout -b "${release_branch}" dev
get_version
wrong_date="$(date)"
correct_date="$(date +%Y-%m-%d)"
cat << EOF > CHANGELOG.md
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [${release_version}] - ${wrong_date}

### Added
- feature ${feature_key}
EOF

git add .
git commit -m "docs(release-${release_version}): Updated CHANGELOG.md"
get_version

# Merge Request for release
echo "Open merge request..."
mr_two="merge-requests/2/merge"
git checkout -b "$mr_two" main
git merge "${release_branch}"
get_version
echo "Found an error that needs fixing..."
# Correction while MR is open
git checkout "${release_branch}"
sed -i "s/${wrong_date}/${correct_date}/g" CHANGELOG.md
git add .
git commit -m "docs(release-${release_version}): fixed typo"
get_version
git checkout "${mr_two}"
git merge "${release_branch}"
echo "Merge request updated..."
get_version

# Merge to main
git checkout main
echo "Merge request approved..."
merge_commit "${release_branch}" main
get_version
echo "Tagging release ${release_version}..."
git tag -a "${release_version}" -m "Release version ${release_version}"
get_version

# Update dev
echo "Updating dev"
git checkout dev
git rebase main
get_version

################################################################################
# Hotfix for a release

echo "=== Hotfix for a release ==="

hotfix_key="FOO-2"
hotfix_branch="hotfix/${hotfix_key}"
git checkout -b "${hotfix_branch}" main
get_version
echo "Critical bug fix" > "${hotfix_key}"
git add .
git commit -m "fix(${hotfix_key}): fixed something"
get_version
major_minor_patch="$(docker run --rm -v "$(pwd):/repo" gittools/gitversion:6.5.1 /repo /showVariable MajorMinorPatch)"
# Update CHANGELOG for hotfix
cat << EOF >> CHANGELOG.md

## [${major_minor_patch}] - $(date +%Y-%m-%d)

### Fixed
- Critical bug
EOF

git add .
git commit -m "docs(hotfix-${hotfix_key}): Updated CHANGELOG.md"
get_version

# Merge Request for hotfix
echo "Open merge request..."
mr_three="merge-requests/3/merge"
git checkout -b "$mr_three" main
git merge "${hotfix_branch}"
get_version

# Merge to main
git checkout main
echo "Merge request approved..."
merge_commit "${hotfix_branch}" main
get_version
echo "Tagging hotfix ${major_minor_patch}..."
git tag -a "${major_minor_patch}" -m "Hotfix version ${major_minor_patch}"
get_version

# Update dev
echo "Updating dev..."
git checkout dev
git rebase main
get_version
