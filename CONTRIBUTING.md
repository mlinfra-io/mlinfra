# Contributing to mlinfra

Thank you for your interest in contributing to this project! I really appreciate that you took your time and interest in contributing `mlinfra`. I'd love to hear from your experience and opinions. Drop me a line in the discord channel.

We appreciate issue reports, pull requests for code and documentation,
as well as any project-related communication through discussions.

## Getting Started

- To get started, first pat yourself!

- `mlinfra` is organised as follows:
    - Docs are in `docs` folder and are built using [mkdocs-material](https://squidfunk.github.io/mkdocs-material/)
    - Python code can be located in `src/mlinfra` repo
    - All terraform modules can be found in `src/mlinfra/modules` folder.

- Fork the `mlinfra` repo and clone it to your local machine.
- Create a python virtual environment and install the dependencies:
```bash
python -m venv venv
source venv/bin/activate
pip install -e .

```
- To update the docs, you'd need to first install the docs dependencies:
```bash
pip install -r requirements-docs.txt
```
- go to `mlinfra` root and run `mkdocs serve` to view the docs locally.

## Types of Contributions

### Report Bug

- The best way to report a bug is to file an issue on GitHub. Please make sure there is an open issue discussing your contribution.
- Before opening a new issue, please check for [existing issues](https://github.com/mlinfra-io/mlinfra/issues). If you find an existing issue that matches closely with yours, please thumbs-up or comment on it, so we know that the issue is relevant to many people. For any new issue please include:
    - Your operating system name and version.
    - Opta version.
    - Detailed steps to reproduce the bug.
    - Any details about your local setup that might be helpful in troubleshooting.
    - When posting Python stack traces, please quote them using [Markdown blocks](https://help.github.com/articles/creating-and-highlighting-code-blocks/).


### Submitting Ideas or Feature Requests

The best way is to file an issue on GitHub:

- Explain in detail how it would work.
- Keep the scope as narrow as possible, to make it easier to implement.

### Improve Documentation

`mlinfra` could always use better documentation, so feel free to create an issue and discuss your changes.

## Bugfix resolution time expectations

- We will respond to all new issues as soon as possible
- For any serious (production breaking) bug we will try to resolve ASAP and do a hotfix release

## Pull Request Guidelines

A philosophy we would like to strongly encourage is

> Before creating a PR, create an issue.

The purpose is to separate problem from possible solutions.

**Bug fixes:** If you’re only fixing a small bug, it’s fine to submit a pull request right away but we highly recommend to file an issue detailing what you’re fixing and its impact. This is helpful in case we don’t accept that specific fix owing to the roadmap but want to keep track of the issue. Please keep in mind that the project maintainers reserve the rights to accept or reject incoming PRs, so it is better to separate the issue and the code to fix it from each other. In some cases, project maintainers may request you to create a separate issue from PR before proceeding.

**Feature/Large changes:** If you intend to change the public API, or make any non-trivial changes to the implementation, we require you to file a new issue and document your thoughts as much as possible. This lets us reach an agreement on your proposal before you put significant effort into it. You are welcome to submit a PR along with the issue (sometimes necessary for demonstration), but we will not review/merge the code until there is an agreement on the issue.

In general, __small PRs__ are always easier to review than __large PRs__. The best practice is to break your work into smaller independent PRs and refer to the same issue. This will greatly reduce turnaround time.

If you wish to share your work which is not ready to merge yet, create a [Draft PR](https://github.blog/2019-02-14-introducing-draft-pull-requests/). This will enable maintainers and the CI runner to prioritize mature PR's.

Finally, please never submit a PR that will put the main branch in broken state. If the PR is part of multiple PRs to complete a large feature and cannot work on its own, you can create a feature branch and merge all related PRs into the feature branch before creating a PR from feature branch to main.

## Code of Conduct

This project and everyone participating in it is governed by the [mlinfra Code of Conduct](https://github.com/mlinfra-io/mlinfra/blob/main/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior via [`ali.abbasjaffri [at] live dot com`](mailto:ali.abbasjaffri@live.com?subject=code-of-conduct-violation-mlinfra).
