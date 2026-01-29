# Development & Infrastructure

## Documentation layers and audiences

We maintain three complementary documentation layers so that readers can find
the right level of detail quickly:

- **Public-facing project narrative (website).** A concise, accessible overview
  of the scientific questions, data, and outputs for a general research
  audience.
- **Developer and contributor guidance (repository docs).** Practical guidance
  for contributors who are working on code, data workflows, and releases.
- **Notebook-style exploratory documentation.** Narrative, iterative analyses
  that capture decisions, prototypes, and analytical context as the project
  evolves.

## Why we built infrastructure first

This project is a multi-site synthesis with long-term data streams. Starting
with shared infrastructure ensures we can harmonize data, track assumptions,
and reuse workflows from the beginning instead of retrofitting them later.

## The R package: what exists now vs what comes later

**Now**

- Core R package scaffold (`lterSparcMaterialLegacy`) with consistent structure.
- Utilities and early helper functions that support data handling and analysis.
- Documentation, vignettes, and a public pkgdown site for discoverability.

**Later**

- Expanded data harmonization pipelines and cross-site synthesis functions.
- Additional vignettes that document finalized analyses.
- Release-ready functions as the scientific results stabilize.

## Continuous integration: what runs and why

Our continuous integration (CI) runs cross-platform checks and documentation
builds. This ensures that contributors on different systems can collaborate
without surprises and that package documentation stays in sync with the code.

## Advisory vs enforced checks (incubation phase)

During the incubation phase, some checks are advisory. They surface best
practices and potential issues without blocking progress. As the package matures
and stable functions land, we expect to tighten these checks and move more items
into a required baseline.

## How this will evolve

As the project matures, we will:

- Promote reusable analytical code into the package.
- Increase required test coverage and documentation completeness.
- Communicate any tightening of checks in the repository governance and release
  notes.

## Notebook-to-package flow (simple view)

```text
Exploratory notebooks → stable functions → package utilities → shared analyses
```

Notebooks and exploratory scripts provide the narrative and prototypes that feed
into package functions. The package, in turn, provides reusable building blocks
for analyses that appear in notebooks or future synthesis outputs.
