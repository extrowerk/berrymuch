#!/usr/bin/env bash

set -e
source ../../lib.sh
TASK=fetch
DISTVER=cmake-3.13.0
#DISTVER=cmake-3.13.5
#DISTVER=cmake-3.16.5
DISTSUFFIX=tar.gz

DISTFILES="https://cmake.org/files/v3.13/$DISTVER.$DISTSUFFIX"
UNPACKCOMD="tar -zxvf"

package_init "$@"

# we must have build libuuid first - see LIBUUID_DIR below
CONFIGURE_CMD="PBTARGETARCH=\"$PBTARGETARCH\"
              PREFIX=\"$PREFIX\"
              QNX_TARGET=\"$QNX_TARGET\"
              cmake --trace \
	      -DCMAKE_REQUIRED_LIBRARIES=\"-lsocket -lelf\" \
              -DCMAKE_TOOLCHAIN_FILE=\"$EXECDIR/blackberry.toolchain.cmake\" \
              -DCMAKE_BUILD_TYPE=release ."

              #-DCMAKE_USE_SYSTEM_CURL=ON \

	      #-DZLIB_INCLUDE_DIRS=/usr/include/net:/usr:/usr/include
	      #-DZLIB_ROOT=/accounts/1000/shared/documents/clitools \

package_fetch
cp $EXECDIR/CMakeLists.txt $WORKDIR/Utilities/cmcurl || exit 1
cp $EXECDIR/OtherTests.cmake $WORKDIR/Utilities/cmcurl/CMake/OtherTests.cmake || exit 1
TASK=build
#package_patch 1
package_build
package_install
package_bundle

