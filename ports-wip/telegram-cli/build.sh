#!/usr/bin/env bash

# This code Copyright 2012 Todd Mortimer <todd.mortimer@gmail.com>
#
# You may do whatever you like with this code, provided the above
# copyright notice and this paragraph are preserved.


set -e
source ../../lib.sh

DISTVER="telegram-cli"
DEPENDS="libevent openssl jansson"

BUILD_DEP_BINS=(lua5.2)
check_required_binaries
TASK=fetch

BUILD_DEP_PKGS=(libc6-dev zlib1g-dev zlib1g:amd64)
# to be checked


#GIT_REPO=https://github.com/kenorb-contrib/tg.git $DISTVER
GIT_TAG=1.3.1

GIT_REPO=https://github.com/berryamin/tg.git
GIT_REPO_TGL=https://github.com/berryamin/tgl.git
GIT_TAG=bb10

package_init "$@"
CONFIGURE_CMD="autoconf ; ./configure 
                --host=$PBHOSTARCH
                --build=$PBBUILDARCH 
                --target=$PBTARGETARCH 
                --prefix=$PREFIX 
		--disable-libconfig
		--disable-liblua
		--disable-json
		--with-openssl=$ARCHIVEDIR/openssl-1.0.2t/$PREFIX
		CFLAGS=\"-I$ARCHIVEDIR/libevent-2.0.22-stable/$PREFIX/include -I$ARCHIVEDIR/lua-5.3.5/$PREFIX\"
		LDFLAGS=\"-L$ARCHIVEDIR/libevent-2.0.22-stable/$PREFIX/lib -L$ARCHIVEDIR/lua-5.3.5/$PREFIX/lib -lsocket -levent\"
                CC=$PBTARGETARCH-gcc
                MAKEINFO='/usr/bin/makeinfo --force'
                "

if [ "$TASK" == "fetch" ]
then
  cd "$WORKROOT"
  [ -d $DISTVER ] || {
	git clone $GIT_REPO $DISTVER
  	cd $DISTVER/
  	git checkout $GIT_TAG

	# TGL library
	git clone $GIT_REPO_TGL tgl
	cd tgl
  	git checkout $GIT_TAG

	cd ..
   }
  cd "$WORKDIR"
  TASK=patch
fi

package_patch 1


if [ "$TASK" == "build" ]
then
  echo "Building"
  cd "$WORKDIR"
  # clean up if we have a previous build
  #if [ -e "Makefile" ]; then
  #  make clean || true
  #  make distclean || true
  #fi

  echo DEBUG: pwd=$(pwd)
  cd tgl/tl-parser
  touch config.h
  make tl-parser CFLAGS="-I/usr/include -I/usr/include/i386-linux-gnu" LDFLAGS="-lz"
  cd ../../

  # configure
  eval $CONFIGURE_CMD
  eval $MAKE_PREFIX make $MYMAKEFLAGS || \
        eval $MAKE_PREFIX make


  TASK=install
fi

package_install
package_bundle


