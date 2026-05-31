#!/bin/sh
WALG_VER="3.0.7"

git init

git clone https://github.com/wal-g/wal-g.git
cd wal-g
git submodule update --init --recursive
git switch -c  v$WALG_VER
rm -Rf .git 
cd ../

git add wal-g
git commit -m "Initial repo"

git checkout -b upstream
git tag  v$WALG_VER

git checkout main
git merge -s ours upstream


mkdir .gear
###########
cat > ".gear/rules" << \EOF
tar: v@version@:wal-g name=wal-g-@version@
diff: v@version@:wal-g wal-g name=wal-g-@version@-@release@.patch
EOF
##########

############
cat > "update.sh" << \EOF
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

EOF
############
chmod +x update.sh


cat > "github_update.sh" << \EOF
WALG_VER=`grep Version wal-g.spec | grep -oE '[0-9.]+'`
git add -A
git commit -m "Update"
git push
git push origin --force --tags
EOF
############
chmod +x github_update.sh



############
cat <<EOF >> "wal-g.spec"
%define PROG_NAME wal-g
%define ALT_ID %(expr `grep VERSION_ID /etc/os-release | cut -d= -f2 | cut -d. -f1` + 0)


Packager:       antioff <nobody@altlinux.org>
Name: %PROG_NAME
Version: $WALG_VER
Release: alt1
Summary: WAL-G is an archival restoration tool for PostgreSQL, MySQL/MariaDB, and MS SQL Server (beta for MongoDB and Redis).
License: Apache-2.0
Group: Databases
# Source https://github.com/wal-g/wal-g/archive/refs/tags/v%version.tar.gz
Url: https://github.com/wal-g/wal-g.git
Source: %PROG_NAME-%version.tar
Patch0:  %PROG_NAME-%version-%release.patch

BuildRequires: curl
BuildRequires: golang
BuildRequires: cmake
BuildRequires: liblzo2-devel
BuildRequires: libbrotli-devel
BuildRequires: libsodium-devel

Requires: liblzo2

%description
WAL-G is an archival restoration tool for PostgreSQL, MySQL/MariaDB,
and MS SQL Server (beta for MongoDB and Redis).
WAL-G is the successor of WAL-E with a number of key differences. 
WAL-G uses LZ4, LZMA, ZSTD, or Brotli compression, multiple processors,
and non-exclusive base backups for Postgres.
More information on the original design and implementation of WAL-G can be found 
on the Citus Data blog post "Introducing WAL-G by Citus: Faster Disaster Recovery for Postgres".


%prep
%setup -n %PROG_NAME-%version
%autopatch -p1

%build
export USE_BROTLI=1
export USE_LIBSODIUM=1
export USE_LZO=1

make deps
make pg_build

%install
m -rf %buildroot
mkdir -p  %buildroot%_bindir
cp main/pg/wal-g %buildroot%_bindir/wal-g-pg



%files
%_bindir


%changelog
* Wed Apr 22 2026 Anton Zamilov <noname@altlinux.org> 3.0.8-alt1
- init wal-g
EOF
#####################
#sed -i 's/Version: WALG_VER/Version: $WALG_VER/g' wal-g.spec


gear-store-tags -ac
git add -A
git commit -m "Init gear"

git remote add origin git@github.com:antioff/wal-g.git
git push -u origin main

git checkout upstream
git push --set-upstream origin upstream
git checkout main



