# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A GitHub composite action (`automadcms/automad-github-backup-action`) that backs up an Automad (flat-file CMS) site to the GitHub repository that runs the workflow. The site files are pulled over SSH with rsync. User-facing setup docs, including an example workflow and the required secrets and variables, are in `README.md`.

There is no build step, no test suite and no linter. To test a change, run the action from a workflow in a separate backup repository (for example via `workflow_dispatch`) and point it at a branch of this repo (`uses: automadcms/automad-github-backup-action@<branch>`).

## Architecture

The two files work as a pipeline:

1. **`action.yml`**: a composite action with three steps:
   - `actions/checkout@v6`, using the `token` input, with `ref` set to the `branch` input. This checks out the *caller's* backup repo into the workspace. An empty `branch` (the default) checks out the branch the workflow runs on. A non-empty `branch` must already exist, otherwise checkout fails.
   - SSH setup: writes `ssh_key_private`/`ssh_key_public` to `~/.ssh/id_rsa{,.pub}` and runs `ssh-keyscan` on `ssh_host` to fill `known_hosts`.
   - Runs `backup.sh` through `${{ github.action_path }}`, passing the inputs as the env vars `SSH_USER`, `SSH_HOST` and `DOCROOT`.
2. **`backup.sh`**: runs with `set -eu`, so any failure fails the workflow.
   - Sets the git identity from `GITHUB_ACTOR`.
   - Runs `rsync -a --delete` from `${SSH_USER}@${SSH_HOST}:${DOCROOT}/` into the checked-out repo root. The exclude list keeps out Automad runtime/config dirs (`/config`, `/cache`, `/bin`, `/pages/.trash`), `sitemap.xml`, and repo metadata (`.git`, `.github`, `.gitignore`, `README.md`, etc.). Because of `--delete`, anything **not** excluded that is missing on the server is deleted from the backup repo. When you add files the backup repo must keep, add an `--exclude` for them.
   - Commits `update content` only if something changed.
   - Writes the current month to `.github/keep-alive` and commits it, so GitHub does not disable scheduled workflows in inactive repos (the 60-day rule).
   - Runs `git push origin HEAD`, which pushes the checked-out branch to the remote branch of the same name.

## Gotchas

- `backup.sh` has a `#!/bin/sh` shebang but is always invoked with `bash`. Keep it POSIX-compatible.
- New action inputs must be declared in `action.yml` `inputs`, mapped into the `env` of the Rsync step, and documented in the README's example workflow and its secrets/variables table.
