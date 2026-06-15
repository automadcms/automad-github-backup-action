#!/bin/sh

set -eux

if [ -z ${SSH_HOST} ]; then
	echo "SSH_HOST is not set. Skipping workflow ..."
	exit 1
fi

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"

if [ -z "${DOCROOT}" ]; then
	echo "DOCROOT is not set. Skipping workflow ..."
	exit 1
fi

echo '----------------------------------'
echo "${DOCROOT} > ${BRANCH}"

rsync -a --stats \
	--delete \
	--exclude=.git \
	--exclude=.github \
	--exclude=.gitignore \
	--exclude=.history \
	--exclude=.editorconfig \
	--exclude=/config \
	--exclude=/cache \
	--exclude=/bin \
	--exclude=/pages/.trash \
	--exclude=sitemap.xml \
	--exclude=README.md \
	${SSH_USER}@${SSH_HOST}:${DOCROOT}/ .

git add -A

if ! git diff --cached --quiet; then
	git commit -m "update content"
fi

echo '----------------------------------'

# Create a monthly commit in order to the keep the action alive.
mkdir -p .github
date +%m >.github/keep-alive

git add -A

if ! git diff --cached --quiet; then
	git commit -m "update keep-alive"
fi

echo '----------------------------------'

git push origin
