import subprocess


class Config:
    def __init__(self):
        self._cache = {}

    def _get_git_config(self, key: str, default: str = "") -> str:
        try:
            result = subprocess.run(
                ["git", "config", "--get", key],
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            return default

    @property
    def strategy(self) -> str:
        return self._get_git_config("semver.strategy", "gitflow")

    @property
    def tag_prefix(self) -> str:
        return self._get_git_config("semver.tagPrefix", "")

    @property
    def gitflow_main(self) -> str:
        return self._get_git_config("semver.gitflow.main", "main")

    @property
    def gitflow_develop(self) -> str:
        return self._get_git_config("semver.gitflow.develop", "develop")

    @property
    def gitflow_feature(self) -> str:
        return self._get_git_config("semver.gitflow.feature", "feature/.*")

    @property
    def gitflow_release(self) -> str:
        return self._get_git_config("semver.gitflow.release", "release/.*")

    @property
    def gitflow_hotfix(self) -> str:
        return self._get_git_config("semver.gitflow.hotfix", "hotfix/.*")
