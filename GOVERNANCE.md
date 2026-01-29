# Governance

## Roles

- **Maintainers** steward the roadmap, review changes, and publish releases.
- **Reviewers** provide subject-matter or code review on pull requests.
- **Contributors** submit issues and pull requests.

## Decision-making

We use a lazy-consensus model: changes are approved if there are no objections
within a reasonable review window. Significant changes should be discussed in
issues first.

## Adding maintainers

New maintainers are nominated by existing maintainers and added after consensus
among current maintainers.

## Release process

1. Update `NEWS.md` with the release notes.
2. Run `R CMD check --as-cran`.
3. Tag the release and publish on GitHub.

## Evolving quality standards

Maintainers may tighten CI rules and documentation requirements over time as
the project matures. Any changes to enforcement will be documented and
communicated in release notes or governance updates.
