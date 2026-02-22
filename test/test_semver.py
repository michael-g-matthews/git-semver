import pytest
from src.semver import SemVer


class TestSemVer:
    def test_init(self):
        v = SemVer(1, 2, 3, "alpha.1", "build.123")
        assert v.major == 1
        assert v.minor == 2
        assert v.patch == 3
        assert v.pre_release == "alpha.1"
        assert v.build == "build.123"

    def test_from_string_simple(self):
        v = SemVer.from_string("1.2.3")
        assert v.major == 1
        assert v.minor == 2
        assert v.patch == 3
        assert v.pre_release is None
        assert v.build is None

    def test_from_string_with_pre_release(self):
        v = SemVer.from_string("1.2.3-alpha.1")
        assert v.major == 1
        assert v.minor == 2
        assert v.patch == 3
        assert v.pre_release == "alpha.1"
        assert v.build is None

    def test_from_string_with_build(self):
        v = SemVer.from_string("1.2.3+build.123")
        assert v.major == 1
        assert v.minor == 2
        assert v.patch == 3
        assert v.pre_release is None
        assert v.build == "build.123"

    def test_from_string_full(self):
        v = SemVer.from_string("1.2.3-alpha.1+build.123")
        assert v.major == 1
        assert v.minor == 2
        assert v.patch == 3
        assert v.pre_release == "alpha.1"
        assert v.build == "build.123"

    def test_from_string_with_v_prefix(self):
        v = SemVer.from_string("v1.2.3", prefix="v")
        assert v.major == 1
        assert v.minor == 2
        assert v.patch == 3

    def test_from_string_invalid(self):
        with pytest.raises(ValueError):
            SemVer.from_string("invalid")

    def test_str(self):
        v = SemVer(1, 2, 3)
        assert str(v) == "1.2.3"

        v = SemVer(1, 2, 3, "alpha.1", "build.123")
        assert str(v) == "1.2.3-alpha.1+build.123"

    def test_eq(self):
        v1 = SemVer(1, 2, 3)
        v2 = SemVer(1, 2, 3)
        v3 = SemVer(1, 2, 4)
        assert v1 == v2
        assert v1 != v3

    def test_lt(self):
        v1 = SemVer(1, 2, 3)
        v2 = SemVer(1, 2, 4)
        v3 = SemVer(1, 2, 3, "alpha")
        assert v1 < v2
        assert v3 < v1  # pre-release is lower

    def test_pre_release_comparison(self):
        # Numeric vs non-numeric
        assert SemVer(1, 0, 0, "1") < SemVer(1, 0, 0, "alpha")
        # Lexical
        assert SemVer(1, 0, 0, "alpha") < SemVer(1, 0, 0, "beta")
        # Numeric comparison
        assert SemVer(1, 0, 0, "1") < SemVer(1, 0, 0, "2")
        # Longer pre-release
        assert SemVer(1, 0, 0, "alpha.1") > SemVer(1, 0, 0, "alpha")
        # Example from spec: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta
        assert SemVer(1, 0, 0, "alpha") < SemVer(1, 0, 0, "alpha.1")
        assert SemVer(1, 0, 0, "alpha.1") < SemVer(1, 0, 0, "alpha.beta")

    def test_bump_major(self):
        v = SemVer(1, 2, 3, "alpha", "build")
        bumped = v.bump_major()
        assert bumped.major == 2
        assert bumped.minor == 0
        assert bumped.patch == 0
        assert bumped.pre_release is None
        assert bumped.build is None

    def test_bump_minor(self):
        v = SemVer(1, 2, 3, "alpha", "build")
        bumped = v.bump_minor()
        assert bumped.major == 1
        assert bumped.minor == 3
        assert bumped.patch == 0
        assert bumped.pre_release is None
        assert bumped.build is None

    def test_bump_patch(self):
        v = SemVer(1, 2, 3, "alpha", "build")
        bumped = v.bump_patch()
        assert bumped.major == 1
        assert bumped.minor == 2
        assert bumped.patch == 4
        assert bumped.pre_release is None
        assert bumped.build is None
