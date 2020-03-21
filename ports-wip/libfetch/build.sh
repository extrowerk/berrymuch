
# This code Copyright 2020 LxMx Foundation
#
# You may do whatever you like with this code, provided the above
# copyright notice and this paragraph are preserved.

set -e
source ../../lib.sh
DISTVER="libfetch-bmuch-0.45"
DISTSUFFIX="tar.gz"

DISTFILES="https://github.com/BerryFarm/libfetch/releases/download/bmuch-0.45/$DISTVER.$DISTSUFFIX"
UNPACKCOMD="tar -xf"

TASK=fetch

package_init "$@"

package_fetch
package_patch

if [ "$TASK" == "build" ]
then
  cd "$WORKDIR"

  OPENSSL_DIR="openssl-1.0.2t"
  CFLAGS="-I$ARCHIVEDIR/$OPENSSL_DIR/$PREFIX/include"
  LDFLAGS="-L$ARCHIVEDIR/$OPENSSL_DIR/$PREFIX/lib"
  LIBS="-lssl -lcrypto"

  eval "CC=$PBTARGETARCH-gcc CFLAGS=$CFLAGS LDFLAGS=$LDFLAGS LIBS=\"$LIBS\"" make

  TASK=install
fi

if [ "$TASK" == "install" ]
then
  cd "$WORKDIR"
  make DESTDIR="$DESTDIR" PREFIX="$PREFIX" install
  TASK=bundle
fi

package_bundle

