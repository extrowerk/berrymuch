
# common functions for the build tools

# This code Copyright 2012 Todd Mortimer <todd.mortimer@gmail.com>
#
# You may do whatever you like with this code, provided the above
# copyright notice and this paragraph are preserved.
#
# Olivier Kaloudoff <olivier.kaloudoff@gmail.com>, 2018


PBHOSTARCH=arm-unknown-nto-qnx8.0.0eabi
PBBUILDARCH=`gcc -dumpmachine`
PBTARGETARCH=arm-unknown-nto-qnx8.0.0eabi

DEFAULTPREFIX='/accounts/1000/shared/documents/clitools'

usage()
{
cat << EOF
usage: $0 options

Run this to fetch, patch, build, bundle and deploy dev tools for the playbook.

OPTIONS:
   -h      Show this message
   -b      The absolute path to your BB Native SDK folder [/abs/path/tp/bbndk]
   -p      The prefix on your BB10 device to install to (default $DEFAULTPREFIX)
   -t      The build task to perform: [ build | build_and_deploy | bundle | deploy]
   -s      The task to pass to each package [fetch | patch | build | install | bundle]
EOF
}

process_args()
{
  SUBTASKFLAG=
  SUBTASK=
  while getopts "b:t:hs:p:" OPTION
  do
    case "$OPTION" in
      h) usage; exit 1;;
      b) echo "$OPTARG" > conf/bbtools;;
      p) echo "$OPTARG" > conf/prefix;;
      t) TASK="$OPTARG";;
      s) SUBTASK="$OPTARG"; SUBTASKFLAG="-t";;
    esac
  done

}

function check_required_binaries()
{
	I=0
	while [ -z != ${BUILD_DEP_BINS[$I]} ];
	do
		type ${BUILD_DEP_BINS[$I]} || {
			echo "Fatal: binary ${BUILD_DEP_BINS[$I]} not found. Required for build"
			exit 1
		}
		let I=$(($I+1))
	done
}

function source_bbtools()
{
  if [ -e "$ROOTDIR/conf/bbtools" ]; then
    BBTOOLS=`cat "$ROOTDIR/conf/bbtools"`
  else
    usage
    exit 1
  fi

  # test the existence of the bbndk-env file
  if ! ls $BBTOOLS/bbndk-env*.sh >/dev/null 2>&1
  then
    echo "Cannot source $BBTOOLS/bbndk-env.sh. Pass -b [path] to specify."
    exit 1
  fi

  # and source
  source $BBTOOLS/bbndk-env*.sh
  TARGETNAME=`basename $(dirname $QNX_TARGET)`

}

function get_prefix()
{
  PREFIX="$DEFAULTPREFIX"
  if [ -e "$ROOTDIR/conf/prefix" ]; then
    PREFIX=`cat "$ROOTDIR/conf/prefix"`
  fi
}

function init_confdir()
{
  mkdir -p conf
  # cache the root directory if we haven't yet
  if [ ! -e "conf/rootdir" ]; then
    echo "$PWD" > conf/rootdir
  fi
}

function configure_dirs()
{
  # we are either the root build.sh, or a subdir
  if [ -e "conf/rootdir" ]; then
    ROOTDIR=`cat conf/rootdir`
  elif [ -e ../../conf/rootdir ]; then
    ROOTDIR=`cat ../../conf/rootdir`
  else
    # first run
    init_confdir
    ROOTDIR=`cat conf/rootdir`
  fi
  DESTDIR="$ROOTDIR/clitools"
  mkdir -p "$DESTDIR"
  ARCHIVEDIR="$ROOTDIR/archive"
  mkdir -p "$ARCHIVEDIR"
  PKGDIR="$ROOTDIR/packages"
  mkdir -p "$PKGDIR"
  WORKROOT="$ROOTDIR/work"
  mkdir -p "$WORKROOT"
  PORTSDIR="$ROOTDIR/ports"
  ZIPFILE="$ROOTDIR/clitools.zip"
}

function init()
{
  init_confdir
  process_args "$@"
  configure_dirs
  source_bbtools
  get_prefix
}

function build_all()
{
  ALLPORTS="bash bc bison bzip2 cflow coreutils cronie diffutils ed fakeroot file findutils gcc gdbm gettext grep groff gzip ircii jansson libevent libmpg123 libuuid m4 make man oniguruma jq openssh openssl ca-certificates curl git lynx patch rsync sc sqlite tar taskwarrior tig tmux vim wget xz yaml youtube-dl zeromq zlib ansiweather"
  ALLPORTS="gdbm gettext grep groff gzip ircii jansson libevent libmpg123 libuuid m4 make man oniguruma jq openssh openssl ca-certificates curl git lynx patch rsync sc sqlite tar taskwarrior tig tmux vim wget xz yaml youtube-dl zeromq zlib ansiweather"
  BROKEN="gdb gcc"

  cd "$PORTSDIR"
  for dir in $ALLPORTS
  do
    if [ -d "$dir" ] && [ -e "$dir/build.sh" ]; then
      echo "Building $dir"

      cd "$dir"
      ./build.sh $SUBTASKFLAG $SUBTASK
      cd "$PORTSDIR"
    fi
  done
}

function subusage()
{
cat << EOF
usage: $0 options

Run this to fetch, patch, build, bundle and deploy $DISTVER for the playbook.

OPTIONS:
   -h      Show this message
   -b      The absolute path to your BB Native SDK folder [/abs/path/tp/bbndk]
   -t      The build task to start at: [fetch | patch | build | install | bundle]
   -p      The prefix on your BB10 device to install to (default $DEFAULTPREFIX)
EOF
}

function process_subargs()
{
while getopts "b:t:hp:" OPTION
do
  case "$OPTION" in
    h) subusage; exit 1;;
    b) echo "$OPTARG" > "$ROOTDIR/conf/bbtools";;
    p) echo "$OPTARG" > "$ROOTDIR/conf/prefix";;
    t) TASK="$OPTARG";;
  esac
done
}

function package_init()
{
  configure_dirs
  process_subargs "$@"
  source_bbtools
  get_prefix

  EXECDIR="$PWD"
  WORKDIR="$WORKROOT/$DISTVER"
  mkdir -p "$WORKDIR"
  ZIPFILE="$PKGDIR/$DISTVER.zip"
}

function package_fetch()
{
if [ "$TASK" == "fetch" ]
then
  cd "$WORKROOT"
  echo "Fetching sources"
  if [ ! -f $DISTVER.$DISTSUFFIX ]; then
    curl -fkSLO $DISTFILES
  fi

  # Unpack and organize
  echo "Unpacking"
  $UNPACKCOMD $DISTVER.$DISTSUFFIX $UNPACKSUFFIX
  TASK=patch
fi
}

function package_patch()
{
if [ "$TASK" == "patch" ]
then
  echo "Patching .. "
  cd "$WORKDIR"
  PATCHLEVEL=$1
  if [ -z $1 ]; then
    PATCHLEVEL=0
  fi
  if [ -e "$EXECDIR/patches" ]; then
    for apatch in $EXECDIR/patches/*
    do
      patch -p$PATCHLEVEL < $apatch
    done
  fi
  TASK=build
fi
}

function package_build()
{
if [ "$TASK" == "build" ]
then
  echo "Building"
  cd "$WORKDIR"
  # clean up if we have a previous build
  #if [ -e "Makefile" ]; then
  #  make clean || true
  #  make distclean || true
  #fi
  eval $CONFIGURE_CMD
  eval $MAKE_PREFIX make $MYMAKEFLAGS || \
  eval $MAKE_PREFIX make
  TASK=install
fi
}

function package_install()
{
if [ "$TASK" == "install" ]
then
  cd "$WORKDIR"
  make DESTDIR="$DESTDIR" install
  TASK=bundle
fi
}

function package_bundle()
{
if [ "$TASK" == "bundle" ]
then
  echo "Bundling"
  cd "$DESTDIR/$PREFIX"

  cp "$ROOTDIR/+BUILD_INFO" .
  echo '' > "+COMMENT"
  echo '' > "+DESC"

  find . -type f| awk -F '\\.\\/' '{print $2}' | grep -v '^+' > /tmp/PLIST

  echo "@cwd $PREFIX"                                                > +CONTENTS
  echo "@name $DISTVER"                                             >> +CONTENTS
  cat /tmp/PLIST                                                    >> +CONTENTS
  echo "@cwd ."                                                     >> +CONTENTS
  echo -e "@ignore\n+COMMENT\n@ignore\n+DESC\n@ignore\n+BUILD_INFO" >> +CONTENTS

  tar zcpvf "$PKGDIR/$DISTVER.tgz" +CONTENTS +COMMENT +DESC +BUILD_INFO $(cat /tmp/PLIST | tr '\n' ' ')

  mv "$DESTDIR" "$ARCHIVEDIR/$DISTVER"
fi
}

# we call configure_dirs here so when the library is included,
# the directories get set up early.
configure_dirs

