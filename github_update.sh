WALG_VER=`grep Version wal-g.spec | grep -oE '[0-9.]+'`
git add -A
git commit -m "Update"
git push
git push origin --force --tags
