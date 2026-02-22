# git-semver — MVP Development Plan
This document is a **work plan** for implementing the initial MVP of `git-semver`.
`git-semver` is a Git-native semantic versioning tool.

## 0. Out of Scope for MVP

To avoid scope creep, the following are **not part of the MVP**:

* Multiple strategies beyond GitFlow
* Strategy auto-detection
* Plugin loading / dynamic extensions
* Writing to Git (no tagging, no commits)
* CI/CD integrations
* Performance optimizations
* UX polish

## 1. High-Level Architecture
```
CLI (git semver)
  └── Version Engine
        ├── GitRepo (Git adapter)
        ├── GitFlowStrategy
        └── SemVer model
```
Each layer shall be **independently testable**.

## 2. Repository & Project Setup
```
git_semver/
├── git_semver/
│   ├── __init__.py
│   ├── cli.py
│   ├── repository.py
│   ├── semver.py
│   ├── result.py
│   ├── strategy/
│   │   ├── __init__.py
│   │   └── gitflow.py
│   └── config.py
├── tests/
│   ├── fixtures/
│   ├── test_semver.py
│   ├── test_repository.py
│   └── test_gitflow.py
├── pyproject.toml
└── README.md
```

## 3. Semantic Version (`SemVer`)
Semantic Versioning follows the official [specification](https://semver.org).

### Goals
* Git agnostic
* Fully deterministic

### Tasks
* Implement `SemVer(major, minor, patch, pre_release, build)`
* Parsing from string (`v1.2.3`, `1.2.3`, `1.2.3-foo.4+5`)
* String rendering
* Comparison operators
* Bump helpers:
  * `bump_major()`
  * `bump_minor()`
  * `bump_patch()`

### Tests
* Parsing valid/invalid versions
* Comparison ordering
* Bump correctness

### Deliverables
* `semver.py`
* `test_semver.py`

## 4. Result Model (`VersionResult`)

### Goals
* Stable output contract between engine and CLI.

### Fields
* `version: SemVer`
* `base_tag: Optional[str]`
* `commits_since_base: int`
* `branch: str`
* `dirty: bool`

### Helpers
* `as_string()` → `1.2.3-alpha.4+5`
* `as_json()` → dict

### Tests
* String formatting
* JSON serialization

### Deliverable
* `result.py`

## 5. Git Adapter (`Repository`)

### Goal
* Abstract Git CLI into a testable boundary.
* Should have concepts for:
    * Commits
    * Tags
    * Branches
    * Git Topology

### Required methods:
* `head() -> Commit`
* `branches_at(Commit) -> list[str]`
* `tags_reachable_from(Commit) -> list[Tag]`
* `merge_base(a, b) -> Commit`
* `is_ancestor(a, b) -> bool`
* `commits_since(a, b) -> int`
* `is_dirty() -> bool`

### CLI-backed Implementation
* Use `subprocess`
* No caching initially

### Tests
* Mocked subprocess output
* Integration tests using real fixture repos

### Deliverable
* `repository.py`
* `test_repository.py`

## 6. Configuration Layer
Git-Native Config Access

### Goal
* All configuration sourced via `git config`.
* Handle some customization

### Responsibilities:
* Read values with defaults
* Handle missing keys gracefully

### Config customization

* Select strategy
* Specify a version prefix that exists in tags
* Specify pre-release formatting
* Specify build information formatting
* Specify branch classification rules (depends on strategy)

```ini
[semver]
strategy = <str>
tagPrefix = <regex>


[semver.gitflow]
main = main
develop = develop
feature = feature/.*
release = release/.*
hotfix = hotfix/.*
```

### Tests
* Missing config
* Overridden config

### Deliverable
* `config.py`

## 7. GitFlow Strategy (Core MVP Logic)

### 7.1 Branch Classification
#### Goal
* Map branch name → GitFlow role.

### Roles
* `main`
* `develop`
* `feature`
* `release`
* `hotfix`
* `unknown`

#### Rules
* Regex-based
* Most specific match wins

#### Tests
* Branch name classification

### 7.2 Base Version Resolution

#### Goal
* Determine the SemVer version that represents the line of development the current commit belongs to.

#### Terminology
* Reachable tag: a tag whose commit is an ancestor of the current commit.

#### Rules
* `main`: base is nearest reachable tag
* `develop`: base is latest tag that is also reachable from main
* `feature`: inherits from develop
* `release`: base is version in release branch name OR inherits from develop
* `hotfix`: base is latest tag that is also reachable from main

#### Tests
* Repos with multiple tags
* No-tag scenarios

### 7.3 Version Calculation

#### Goal
* Apply strategy semantics. In this case, the strategy is GitFlow.

#### Example GitFlow rules (subject to refinement):

| Role    | Base Version | Bump  | Prerelease  |
| ------- | ------------ | ----- | ----------- |
| main    | specific tag | none  | none        |
| develop | main tag     | minor | alpha.N     |
| feature | develop      | none  | feature.X.N |
| release | develop      | none  | rc.N        |
| hotfix  | main tag     | patch | rc.N        |

where N is number of commits ahead of base. X is either a string (branch name) 
or number (issue number) denoting the feature branch.

#### Tests
* Commit distance
* Branch transitions

#### Deliverable
* `strategy/gitflow.py`
* `test_gitflow.py`

## 8. Version Engine
### Goal
* Glue repo + strategy -> result.

### Steps:
1. Load config
2. Create `GitRepo` object
3. Resolve computation rules via strategy
4. Compute `VersionResult`

### Deliverable
* Minimal engine code (likely inside CLI initially)

## 9. Command Line Interface (`git semver`)

### Supported flags:
* `--json` (prints important information as key-value pairs)
* `--print-base` (prints version, and commit used as the base)
* `--dirty` 
* `--short` (prints Major.Minor.Patch)
* `--verbose` (show debugging/trace steps)

### Behavior
* Default: print SemVer string only
* Errors are human-readable

### Tests
* Output tests

### Deliverable
* `cli.py`

## 10. Test Fixtures (Preview)
Fixtures will be **real Git repositories** with scripted history:
* gitflow-basic
* gitflow-feature
* gitflow-hotfix
* no-tags
* detached-head

Each fixture documents:
* commit graph
* branches
* tags
* expected output

## 11. Packaging (Deferred but Planned)

### Initial
* Python package
* `pipx install git-semver`

### Later
* PyInstaller static binary
* Go/C++ rewrite

## 12. Definition of MVP Done

MVP is complete when:

* [ ] `git semver` works in GitFlow repos
* [ ] Output is deterministic and documented
* [ ] Tests cover all supported branch roles
* [ ] No Git writes occur
* [ ] README explains behavior clearly
