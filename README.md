# Automad GitHub Backup Action

[Automad](https://automad.org) is a flat-file CMS — everything lives in files, no database fuss. That means backing up your whole site is super easy, and pushing it to a Git repository is one of the best perks. This GitHub Action makes it effortless: set it up once, and your site is safely backed up to GitHub automatically.

## What You’ll Need

Before you get started, make sure you have a few things ready. You’ll need a shared hosting or VPS environment that supports SSH with key-based authentication. You’ll also need a private/public SSH key pair, which you can generate on any Unix-like machine using ssh-keygen, and the public key must be installed on your host so the action can connect securely.

## How to Use It

Getting started is easy. First, create a fresh GitHub repository where your backup will be stored. Then, add a GitHub workflow file to that repository, for example `./github/workflows/backup.yml`, and paste the following content:

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

Next, configure the repository secrets and variables exactly as referenced in your workflow file.

| Name              | Type     | Description                                           |
| ----------------- | -------- | ----------------------------------------------------- |
| `SSH_KEY_PRIVATE` | secret   | A private SSH key that can be used to access the host |
| `SSH_KEY_PUBLIC`  | secret   | The matching public key                               |
| `SSH_USER`        | secret   | The SSH username                                      |
| `SSH_HOST`        | variable | The target machine where Automad is installed         |
| `DOCROOT`         | variable | The path to the installation on the target machine    |

> [!NOTE]
> The workflow runs on a schedule, which you can configure directly in the YAML file. In the example, it’s set to run every Sunday at 4:00 AM, but you can adjust it to fit your own backup routine.

Once everything is set up, your Automad site will automatically back up to GitHub, giving you one less thing to worry about while you focus on building your site.
