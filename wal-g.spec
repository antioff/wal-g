%define PROG_NAME wal-g
%define ALT_ID %(expr 11 + 0)


Packager:       antioff <nobody@altlinux.org>
Name: %PROG_NAME
Version: 3.0.8
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
