#!/bin/sh

repo="./packages"

[ -f $repo/pkg_summary.gz ] && rm $repo/pkg_summary.gz

for i in $repo/*; do
  name=$(basename $i | sed -e 's/.tgz//')

  echo "PKGNAME=$name"     >> $repo/pkg_summary
  echo "COMMENT="          >> $repo/pkg_summary
  cat repo/+BUILD_INFO     >> $repo/pkg_summary
  echo -e "DESCRIPTION=\n" >> $repo/pkg_summary
done

gzip $repo/pkg_summary
