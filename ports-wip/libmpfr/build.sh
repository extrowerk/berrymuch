#!/usr/bin/env bash

set -x

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
  echo "Fetching libmpfr sources if not already present"
pwd
  ls -d work/$DISTVER/tools 2>/dev/null 2>&1 || \
{
  cd work/$DISTVER
  git init
  git config core.sparseCheckout true
  echo "tools/libmpfr/branches/710_release/" >> .git/info/sparse-checkout
  git remote add -f origin https://github.com/extrowerk/core-dev-tools.git
  git pull origin master
}

  TASK=build
fi

# Target have to be --target=arm-unknown-nto-qnx8.0.0eabi
CONFIGURE_CMD="cd $EXECDIR/work/710_release/tools/libmpfr/branches/710_release/;
				./configure 
                --host=$PBHOSTARCH
                --build=$PBBUILDARCH 
                --target=$PBTARGETARCH 
                --prefix=$PREFIX 
                CC=$PBTARGETARCH-gcc 
                CFLAGS=\"-I$PWD\"
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


