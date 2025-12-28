# Automad GitHub Backup Action

Create Automad backups to a GitHub repository using rsync over SSH.

## Usage

In order to enable scheduled backups of an Automad site to a GitHub repository, add the following workflow to an empty repository in `./github/workflows/backup.yml`.

```yml
name: GitHub Backup

on:
  schedule:
    - cron: "0 4 * * 0"
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Backup Action
        uses: automadcms/automad-github-backup-action@1.0.0
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          ssh_key_private: ${{ secrets.SSH_KEY_PRIVATE }}
          ssh_key_public: ${{ secrets.SSH_KEY_PUBLIC }}
          ssh_user: ${{ secrets.SSH_USER }}
          ssh_host: ${{ vars.SSH_HOST }}
          docroot: ${{ vars.DOCROOT }}
          branch: master
```

With workflow, the backup runs weekly on sundays at 4:00h. Note that for the example above, you also have to add the following secrets and variables in the repository settings:

| Name              | Type     | Description                                           |
| ----------------- | -------- | ----------------------------------------------------- |
| `SSH_KEY_PRIVATE` | secret   | A private SSH key that can be used to access the host |
| `SSH_KEY_PUBLIC`  | secret   | The matching public key                               |
| `SSH_USER`        | secret   | The SSH username                                      |
| `SSH_HOST`        | variable | The target machine where Automad is installed         |
| `DOCROOT`         | variable | The path to the installation on the target machine    |

### About SSH Keys

This action authenticates to the host machine via SSH using a private/public key pair. You can generate such a key on any Linux or macOS machine.
