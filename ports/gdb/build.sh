#!/bin/bash -x

# This code Copyright 2012 Todd Mortimer <todd.mortimer@gmail.com>
#
# You may do whatever you like with this code, provided the above
# copyright notice and this paragraph are preserved.
#
# Olivier Kaloudoff <olivier.kaloudoff@gmail.com>, 2018
#


set -e
source ../../lib.sh
#DISTVER="gdb-6.6a"
V=3
DISTVER="gdb-6.${V}a"
DISTSUFFIX="tar.bz2"
BUILD_DEP=(gmp-6.1.2)
TASK=fetch


DISTFILES="ftp://sourceware.org/pub/gdb/old-releases/$DISTVER.$DISTSUFFIX"
UNPACKCOMD="tar -xjf"
package_init "$@"
CONFIGURE_CMD="./configure --prefix=$PREFIX
                --host=$PBHOSTARCH
                --build=$PBBUILDARCH
                --target=$PBTARGETARCH
                CFLAGS=-I../gmp-6.1.2
                LDFLAGS=\"-lgmp -L../gmp-6.1.2\"
                "

if [ "$TASK" == "build" ]
then
  cd "$WORKROOT/$DISTVER"
  scons
  TASK=install
fi


package_fetch
echo $(pwd)

# 6.xa creates 6.x/ ...
rmdir $WORKROOT/gdb-6.${V}a || exit 1
mv $WORKROOT/gdb-6.$V $WORKROOT/gdb-6.${V}a || exit 1

# 6.6a creates 6.6/ ...
#rmdir $WORKROOT/gdb-6.6a || exit 1
#mv $WORKROOT/gdb-6.6 $WORKROOT/gdb-6.6a || exit 1

check_required_packages $BUILD_DEP
unpack_required_packages $BUILD_DEP
package_patch 1
package_build
package_install
package_bundle

