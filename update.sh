#!/bin/sh
WALG_VER=v`grep Version wal-g.spec | grep -oE '[0-9.]+'`

git add -A
git commit -m "Update main branch $WALG_VER"

git checkout upstream

rm -Rf wal-g
git clone https://github.com/wal-g/wal-g.git
cd wal-g
git submodule update --init --recursive
git switch -c  v$WALG_VER
rm -Rf .git 

cd ../

git add -A
git commit -m "Update submodule WAL_G"
git tag -f "$WALG_VER"

git checkout main
gear-store-tags -ac

git merge upstream -m "Merge with upstream WAL-G $WALG_VER"

git add -A
git commit -m "Update version WAL-G $WALG_VER"

