#!/usr/bin/env bash

set -e

source lib.sh

init "$@"

cd "$ROOTDIR/base"

echo "Setting up target env"
echo "NATIVE_TOOLS=\"$PREFIX\""                    > env.sh
echo "QNX_TARGET=\$NATIVE_TOOLS/$TARGETNAME/qnx6" >> env.sh
echo "export NATIVE_TOOLS QNX_TARGET"             >> env.sh
cat env_footer.sh                                 >> env.sh

echo "umask 002"                       >  sample_profile
echo "CLITOOLS_ENV=\"$PREFIX/env.sh\"" >> sample_profile
echo 'if [ -e $CLITOOLS_ENV ]; then'   >> sample_profile
echo '    . $CLITOOLS_ENV'             >> sample_profile
echo 'fi'                              >> sample_profile

archive="clitools.tgz"
tar zcpvf $archive env.sh qconf-override.mk sample_profile ../packages

echo "#!/bin/sh"                      >  install.sh
echo "mkdir -p \"$PREFIX\""           >> install.sh
echo "mv \"$archive\" \"$PREFIX\""    >> install.sh
echo "cd \"$PREFIX\""                 >> install.sh
echo "tar zxvf \"$archive\""          >> install.sh
echo "tar zxvf packages/pkg_install*" >> install.sh
echo '. ./env.sh'                     >> install.sh
echo 'mkdir -p var/db/pkg'            >> install.sh
echo 'for pkg in packages/*.tgz'      >> install.sh
echo 'do'                             >> install.sh
echo 'pkg_add $pkg'                   >> install.sh
echo 'done'                           >> install.sh
cat install_footer.sh                 >> install.sh

echo "---- You can now download $archive and install.sh to your device from http://thismachine:8888"
python3 -m http.server 8888
