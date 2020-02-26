#!/usr/bin/env bash

# This code Copyright 2020 LxMx Foundation
#
# You may do whatever you like with this code, provided the above
# copyright notice and this paragraph are preserved.
#

set -e
source ../../lib.sh

DISTVER="fetch"

LIBFETCH_DIR="libfetch-xbps-2.0"
LIBNBCOMPAT_DIR="libnbcompat-20180822"
OPENSSL_DIR="openssl-1.0.2t"

BUILD_DEP_BINS=(bmake)
check_required_binaries

TASK=fetch
package_init "$@"

CONFIGURE_CMD=" ./configure
                --host=$PBHOSTARCH
                --build=$PBBUILDARCH
                --target=$PBTARGETARCH
                --prefix=$PREFIX"

if [ "$TASK" == "fetch" ]
then
  cd "$WORKROOT"

  rm -rf "$DISTVER"
  cp -R $EXECDIR/files $DISTVER

  TASK=patch
fi

package_patch

if [ "$TASK" == "build" ]
then
  cd "$WORKDIR"
  eval $CONFIGURE_CMD

  CPPFLAGS="-I$ARCHIVEDIR/$LIBFETCH_DIR/$PREFIX/include\
    -I$ARCHIVEDIR/$LIBNBCOMPAT_DIR/$PREFIX/include\
    -I$ARCHIVEDIR/$OPENSSL_DIR/$PREFIX/include"
  LDFLAGS="-L$ARCHIVEDIR/$LIBFETCH_DIR/$PREFIX/lib\
    -L$ARCHIVEDIR/$LIBNBCOMPAT_DIR/$PREFIX/lib\
    -L$ARCHIVEDIR/$OPENSSL_DIR/$PREFIX/lib"
  CC=$PBTARGETARCH-gcc

  eval "CC=$PBTARGETARCH-gcc CPPFLAGS=\"$CPPFLAGS\" LDFLAGS=\"$LDFLAGS\" LIBS=\"$LIBS\" bmake"

  TASK=install
fi

if [ "$TASK" == "install" ]
then
  cd "$WORKDIR"

  mkdir -p $DESTDIR/$PREFIX/{man/man1,bin}
  bmake DESTDIR="$DESTDIR/$PREFIX" STRIPFLAG="" MANDIR="/man" install

  mv $DESTDIR/$PREFIX/fetch $DESTDIR/$PREFIX/bin/fetch

  TASK=bundle
fi

package_bundle

