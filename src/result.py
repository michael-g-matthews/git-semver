from typing import Optional
import json
from .semver import SemVer


class VersionResult:
    def __init__(
        self,
        version: SemVer,
        base_tag: Optional[str],
        commits_since_base: int,
        branch: str,
        dirty: bool,
    ):
        self.version = version
        self.base_tag = base_tag
        self.commits_since_base = commits_since_base
        self.branch = branch
        self.dirty = dirty

    def as_string(self) -> str:
        return str(self.version)

    def as_json(self) -> str:
        return json.dumps(
            {
                "version": str(self.version),
                "base_tag": self.base_tag,
                "commits_since_base": self.commits_since_base,
                "branch": self.branch,
                "dirty": self.dirty,
            }
        )
