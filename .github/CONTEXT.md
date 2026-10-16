# GitHub automation context

**Purpose:** CI and publishing configuration for INNATE.

**Key files:** See `workflows/deploy-pages.yml` and `workflows/CONTEXT.md`.

**Connections:** The new publishing job runs only for changes pushed to `main`. The repo's default-branch and Pages-source settings must also be switched to `main` and GitHub Actions in the GitHub UI.

**Change & verify:** Check Actions runs before claiming a deployment. Publishing can be blocked by Pages settings or environment rules even after a successful Godot export.
