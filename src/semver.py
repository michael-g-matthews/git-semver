import re
from typing import Optional

# This implementation is based on the Semantic Versioning 2.0.0 specification.
# See: https://semver.org/
# Licensed under Creative Commons Attribution 3.0 Unported License.
# https://creativecommons.org/licenses/by/3.0/


class SemVer:
    def __init__(
        self,
        major: int,
        minor: int = 0,
        patch: int = 0,
        pre_release: Optional[str] = None,
        build: Optional[str] = None,
    ):
        self.major = major
        self.minor = minor
        self.patch = patch
        self.pre_release = pre_release
        self.build = build

    @classmethod
    def from_string(cls, version: str, prefix: str | None = None) -> "SemVer":
        # Remove leading prefix if present
        if prefix:
            version = version.removeprefix(prefix)

        # Official SemVer regex with named capture groups
        pattern = r"^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<pre_release>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"
        match = re.match(pattern, version)
        if not match:
            raise ValueError(f"Invalid SemVer string: {version}")

        groups = match.groupdict()
        return cls(
            int(groups["major"]),
            int(groups["minor"]),
            int(groups["patch"]),
            groups["pre_release"],
            groups["buildmetadata"],
        )

    def __str__(self) -> str:
        version = f"{self.major}.{self.minor}.{self.patch}"
        if self.pre_release:
            version += f"-{self.pre_release}"
        if self.build:
            version += f"+{self.build}"
        return version

    def __repr__(self) -> str:
        return f"SemVer({self.major}, {self.minor}, {self.patch}, {self.pre_release!r}, {self.build!r})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, SemVer):
            return NotImplemented
        return (
            self.major == other.major
            and self.minor == other.minor
            and self.patch == other.patch
            and self.pre_release == other.pre_release
            and self.build == other.build
        )

    def __lt__(self, other: "SemVer") -> bool:
        # Compare major, minor, patch numerically
        if (self.major, self.minor, self.patch) != (
            other.major,
            other.minor,
            other.patch,
        ):
            return (self.major, self.minor, self.patch) < (
                other.major,
                other.minor,
                other.patch,
            )

        # If versions are equal, pre-release makes it lower
        if self.pre_release and not other.pre_release:
            return True
        if not self.pre_release and other.pre_release:
            return False
        if self.pre_release and other.pre_release:
            return self._compare_pre_release(self.pre_release, other.pre_release) < 0

        # Build metadata doesn't affect ordering
        return False

    def _compare_pre_release(self, a: str, b: str) -> int:
        """Compare two pre-release strings according to SemVer spec.
        Returns -1 if a < b, 0 if equal, 1 if a > b.
        """
        a_parts = a.split(".")
        b_parts = b.split(".")

        for i in range(max(len(a_parts), len(b_parts))):
            a_part = a_parts[i] if i < len(a_parts) else None
            b_part = b_parts[i] if i < len(b_parts) else None

            if a_part is None and b_part is None:
                continue
            if a_part is None:
                return -1  # a has fewer parts, so a < b
            if b_part is None:
                return 1  # b has fewer parts, so a > b

            # Try to parse as int
            a_num: Optional[int] = None
            b_num: Optional[int] = None
            try:
                a_num = int(a_part)
            except ValueError:
                a_num = None
            try:
                b_num = int(b_part)
            except ValueError:
                b_num = None

            if a_num and b_num:
                if a_num != b_num:
                    return -1 if a_num < b_num else 1
            elif a_num and not b_num:
                return -1  # numeric < non-numeric
            elif not a_num and b_num:
                return 1  # non-numeric > numeric
            else:
                # Both non-numeric, lexical compare
                if a_part != b_part:
                    return -1 if a_part < b_part else 1

        return 0  # equal

    def __le__(self, other: "SemVer") -> bool:
        return self < other or self == other

    def __gt__(self, other: "SemVer") -> bool:
        return not (self <= other)

    def __ge__(self, other: "SemVer") -> bool:
        return not (self < other)

    def bump_major(self) -> "SemVer":
        return SemVer(self.major + 1, 0, 0, None, None)

    def bump_minor(self) -> "SemVer":
        return SemVer(self.major, self.minor + 1, 0, None, None)

    def bump_patch(self) -> "SemVer":
        return SemVer(self.major, self.minor, self.patch + 1, None, None)
