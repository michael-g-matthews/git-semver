import argparse
import sys
from .config import Config
from .repository import Repository
from .strategy.gitflow import GitFlowStrategy
from .result import VersionResult


def main():
    parser = argparse.ArgumentParser(description="Git SemVer tool")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    parser.add_argument(
        "--print-base", action="store_true", help="Print base information"
    )
    parser.add_argument("--dirty", action="store_true", help="Include dirty status")
    parser.add_argument(
        "--short", action="store_true", help="Print Major.Minor.Patch only"
    )
    parser.add_argument("--verbose", action="store_true", help="Verbose output")

    args = parser.parse_args()

    try:
        config = Config()
        repo = Repository()
        head = repo.head()
        branch = repo.current_branch()

        strategy = GitFlowStrategy(repo, config)
        base_version = strategy.resolve_base_version(branch, head)
        result: VersionResult = strategy.calculate_version(branch, head, base_version)

        if args.json:
            print(result.as_json())
        if args.print_base:
            print(f"Version: {result.version}")
            print(f"Base Tag: {result.base_tag}")
            print(f"Commits Since Base: {result.commits_since_base}")
            print(f"Branch: {result.branch}")
            print(f"Dirty: {result.dirty}")
        if args.short:
            print(
                f"{result.version.major}.{result.version.minor}.{result.version.patch}"
            )
        else:
            print(result.as_string())

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
