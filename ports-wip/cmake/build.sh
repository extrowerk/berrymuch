#!/usr/bin/env bash

set -e
source ../../lib.sh
TASK=fetch
DISTVER=cmake-2.8.5
DISTSUFFIX=tar.gz

DISTFILES="https://cmake.org/files/v2.8/$DISTVER.$DISTSUFFIX"
UNPACKCOMD="tar -zxvf"

package_init "$@"

# we must have build libuuid first - see LIBUUID_DIR below
CONFIGURE_CMD="PBTARGETARCH=\"$PBTARGETARCH\"
              PREFIX=\"$PREFIX\"
              QNX_TARGET=\"$QNX_TARGET\"
              cmake \
              -DCMAKE_TOOLCHAIN_FILE=\"$EXECDIR/blackberry.toolchain.cmake\" \
              -DCMAKE_BUILD_TYPE=release ."

package_fetch
package_patch
package_build
package_install
package_bundle

