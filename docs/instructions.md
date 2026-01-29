# How to use this repository

This site summarizes the legacy materials in this repository and points to the primary entrypoints for exploring the data workflows.

## Key pages

- [Workflow](getting-started/workflow.md) for the raw → tidy → graphs flow and where scripts live.
- [Repo structure](getting-started/repo-structure.md) for a quick map of folders and intent.
- [Data](data.md) for expected raw and tidy conventions (with TODOs where sources are unknown).

## Deployment checklist (GitHub Pages)

To publish this site on GitHub Pages, configure the repository settings as follows:

1. **Settings → Pages → Source:** select **GitHub Actions**.
2. **Settings → Actions → Workflow permissions:** set to **Read and write permissions**.

These settings are required for the Pages workflow in `.github/workflows/pages.yml` to deploy successfully.
