#!/bin/sh

if [ -z ${SSH_HOST} ]; then
	echo "SSH_HOST is not set. Skipping workflow ..."
	exit
fi

git config --global url.https://x-access-token:${GITHUB_TOKEN}@github.com/.insteadOf https://github.com/
git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"

if [ -z "${DOCROOT}" ]; then
	return
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
git commit -m "update content"

echo '----------------------------------'

# Create a monthly commit in order to the keep the action alive.
mkdir -p .github
date +%m >.github/keep-alive
git add .
git commit -m "update keep-alive"

echo '----------------------------------'

git push origin
