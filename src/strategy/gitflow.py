from re import match
from typing import Optional, List
from ..semver import SemVer
from ..repository import Repository, Commit, Tag
from ..result import VersionResult


class GitFlowStrategy:
    def __init__(self, repo: Repository, config):
        self.repo = repo
        self.config = config

    def classify_branch(self, branch: str) -> str:
        patterns = {
            "main": self.config.gitflow_main,
            "develop": self.config.gitflow_develop,
            "feature": self.config.gitflow_feature,
            "release": self.config.gitflow_release,
            "hotfix": self.config.gitflow_hotfix,
        }

        for role, pattern in patterns.items():
            if match(pattern, branch):
                return role
        return "unknown"

    def _parse_version_from_tag(self, tag_name: str) -> Optional[SemVer]:
        # Remove prefix if configured
        try:
            return SemVer.from_string(tag_name, self.config.tag_prefix)
        except ValueError:
            return None

    def _get_reachable_tags(self, commit: Commit) -> List[Tag]:
        tags = self.repo.tags_reachable_from(commit)
        return [
            tag for tag in tags if self._parse_version_from_tag(tag.name) is not None
        ]

    def _get_latest_tag_reachable_from_main(self) -> Optional[Tag]:
        main_branch = self.config.gitflow_main
        try:
            main_commit = (
                self.repo.head()
            )  # Assuming main is current, but need to find main commit
            # For simplicity, assume tags on main are reachable
            # TODO: Properly find main branch head
            tags = self._get_reachable_tags(self.repo.head())
            if tags:
                # Sort by version
                tags.sort(
                    key=lambda t: self._parse_version_from_tag(t.name), reverse=True
                )
                return tags[0]
        except:
            pass
        return None

    def resolve_base_version(self, branch: str, commit: Commit) -> Optional[SemVer]:
        role = self.classify_branch(branch)

        if role == "main":
            tags = self._get_reachable_tags(commit)
            if tags:
                tags.sort(
                    key=lambda t: self._parse_version_from_tag(t.name), reverse=True
                )
                return self._parse_version_from_tag(tags[0].name)

        elif role in ["develop", "hotfix"]:
            latest_main_tag = self._get_latest_tag_reachable_from_main()
            if latest_main_tag:
                return self._parse_version_from_tag(latest_main_tag.name)

        elif role == "feature":
            # Inherit from develop
            develop_tag = self._get_latest_tag_reachable_from_main()  # Approximation
            if develop_tag:
                return self._parse_version_from_tag(develop_tag.name)

        elif role == "release":
            # Parse from branch name or inherit from develop
            matches = match(r"release/(.*)", branch)
            if matches:
                try:
                    return SemVer.from_string(matches.group(1))
                except ValueError:
                    pass
            # Fallback to develop
            develop_tag = self._get_latest_tag_reachable_from_main()
            if develop_tag:
                return self._parse_version_from_tag(develop_tag.name)

        return None

    def calculate_version(
        self, branch: str, commit: Commit, base_version: Optional[SemVer]
    ) -> VersionResult:
        role = self.classify_branch(branch)
        dirty = self.repo.is_dirty()

        if not base_version:
            base_version = SemVer(0, 1, 0)  # Default

        commits_since = 0
        base_tag = None

        if role == "main":
            # No bump, use base
            version = base_version
        elif role == "develop":
            version = base_version.bump_minor()
            commits_since = (
                self.repo.commits_since(base_version_commit, commit)
                if base_version_commit
                else 0
            )
            version.pre_release = f"alpha.{commits_since}"
        elif role == "feature":
            # No bump, pre-release
            commits_since = (
                self.repo.commits_since(base_version_commit, commit)
                if base_version_commit
                else 0
            )
            version = base_version
            version.pre_release = f"feature.{branch.split('/')[-1]}.{commits_since}"
        elif role == "release":
            # No bump, rc
            commits_since = (
                self.repo.commits_since(base_version_commit, commit)
                if base_version_commit
                else 0
            )
            version = base_version
            version.pre_release = f"rc.{commits_since}"
        elif role == "hotfix":
            version = base_version.bump_patch()
            commits_since = (
                self.repo.commits_since(base_version_commit, commit)
                if base_version_commit
                else 0
            )
            version.pre_release = f"rc.{commits_since}"
        else:
            version = base_version

        return VersionResult(version, base_tag, commits_since, branch, dirty)


# Note: This is incomplete; need to properly find base commit for commits_since
