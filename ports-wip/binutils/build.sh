#!/usr/bin/env bash

# This code Copyright 2012 Todd Mortimer <todd.mortimer@gmail.com>
#
# You may do whatever you like with this code, provided the above
# copyright notice and this paragraph are preserved.


set -e
source ../../lib.sh
TASK=fetch

DISTVER="710_release"

package_init "$@"

if [ "$TASK" == "fetch" ]
then
  cd "$EXECDIR"
  # fetch
  echo "Fetching binutils sources if not already present"
pwd
  ls -d work/$DISTVER 2>/dev/null 2>&1 || \
{
  cd work/$DISTVER
  git init
  git config core.sparseCheckout true
  echo "tools/binutils/branches/710_release/" >> .git/info/sparse-checkout
  git remote add -f origin https://github.com/extrowerk/core-dev-tools.git
  git pull origin master
}

  TASK=build
fi

# Target have to be --target=arm-unknown-nto-qnx8.0.0eabi
CONFIGURE_CMD="cd "tools/binutils/branches/710_release/";
				find . -name \"config.cache\" -exec rm -rf {} \;;
				export ac_cv_func_ftello64=no;
				export ac_cv_func_fseeko64=no;
				export ac_cv_func_fopen64=no;
				export CFLAGS=\"$CFLAGS -Wno-shadow -Wno-format -Wno-sign-compare\";
				export LIBS=\"$LIBS -liconv\";
				export LDFLAGS=\"$LDFLAGS -liconv\";
				$EXECDIR/work/$DISTVER/tools/binutils/branches/710_release/configure
                   --host=$PBHOSTARCH
                   --build=$PBBUILDARCH
                   --target=$PBTARGETARCH
                   --with-sysroot=$QNX_TARGET
                   --prefix=$PREFIX
                   --exec-prefix=$PREFIX
                   --libdir=$PREFIX/lib
                   --libexecdir=$PREFIX/lib
                   --with-local-prefix=$PREFIX
                   CC=$PBTARGETARCH-gcc
                   LDFLAGS='-Wl,-s '
                   AUTOMAKE=: AUTOCONF=: AUTOHEADER=: AUTORECONF=: ACLOCAL=:
                   "
package_build
package_install

# Do not read further ,this is just the gcc build.sh,  the following part is yet to be done.

cd "$DESTDIR/$PREFIX/bin"
# escape pkgsrc jail
ln -sf ./gcc ./gcc.pkgsrc

# these are broken
rm -rf $DESTDIR/$PREFIX/$TARGETNAME/qnx6/usr/include
cp $EXECDIR/ldd $DESTDIR/$PREFIX/bin/
  
package_bundle

# and pack up the system headers, etc
cd "$BBTOOLS"
zip -r -u -y "$ZIPFILE" $TARGETNAME/qnx6/armle-v7/lib $TARGETNAME/qnx6/usr/include --exclude \*qt4\* || true
zip -r -u -y "$ZIPFILE" $TARGETNAME/qnx6/armle-v7/usr/lib --exclude \*qt4\* || true


