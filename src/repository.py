import subprocess
import re
from typing import List, Optional
from pathlib import Path


class Commit:
    def __init__(self, sha: str):
        if not re.match(r"^[0-9a-fA-F]+$", sha):
            raise ValueError(
                f"Invalid SHA: {sha}. Must be hexadecimal characters only."
            )
        self.sha = sha

    def __str__(self):
        return self.sha

    def __eq__(self, other):
        return isinstance(other, Commit) and self.sha == other.sha


class Tag:
    def __init__(self, name: str, commit: Commit):
        self.name = name
        self.commit = commit

    def __str__(self):
        return self.name


class Repository:
    def __init__(self, path: Optional[Path] = None):
        self.path = path or Path.cwd()

    def _run_git(self, args: List[str]) -> str:
        result = subprocess.run(
            ["git"] + args, cwd=self.path, capture_output=True, text=True, check=True
        )
        return result.stdout.strip()

    def head(self) -> Commit:
        sha = self._run_git(["rev-parse", "HEAD"])
        return Commit(sha)

    def branches_at(self, commit: Commit) -> List[str]:
        # Get branches that contain the commit
        output = self._run_git(
            ["branch", "--contains", commit.sha, "--format=%(refname:short)"]
        )
        return output.splitlines() if output else []

    def tags_reachable_from(self, commit: Commit) -> List[Tag]:
        # Get tags reachable from commit
        output = self._run_git(["tag", "--merged", commit.sha])
        tags = []
        for tag_name in output.splitlines():
            # Get commit for each tag
            commit_sha = self._run_git(["rev-parse", f"{tag_name}^{{}}"])
            tags.append(Tag(tag_name, Commit(commit_sha)))
        return tags

    def merge_base(self, a: Commit, b: Commit) -> Commit:
        sha = self._run_git(["merge-base", a.sha, b.sha])
        return Commit(sha)

    def is_ancestor(self, a: Commit, b: Commit) -> bool:
        try:
            self._run_git(["merge-base", "--is-ancestor", a.sha, b.sha])
            return True
        except subprocess.CalledProcessError:
            return False

    def commits_since(self, base: Commit, head: Commit) -> int:
        # Count commits from base to head, not including base
        output = self._run_git(["rev-list", "--count", f"{base.sha}..{head.sha}"])
        return int(output)

    def is_dirty(self) -> bool:
        # Check if there are uncommitted changes
        try:
            self._run_git(["diff", "--quiet", "--exit-code"])
            self._run_git(["diff", "--cached", "--quiet", "--exit-code"])
            return False
        except subprocess.CalledProcessError:
            return True

    def current_branch(self) -> str:
        try:
            branch = self._run_git(["rev-parse", "--abbrev-ref", "HEAD"])
            return branch
        except subprocess.CalledProcessError:
            return "HEAD"  # Detached HEAD
