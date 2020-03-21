#!/bin/sh

rm pkg_summary

for i in packages/*; do
  name=$(basename $i | sed -e 's/.tgz//')

  echo "PKGNAME=$name"  >> pkg_summary
  echo "COMMENT="       >> pkg_summary
  cat +BUILD_INFO       >> pkg_summary
  echo -e "DESCRIPTION=\n" >> pkg_summary
done
