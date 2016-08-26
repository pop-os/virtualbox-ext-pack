#!/bin/sh

set -ex

if [ $# -ne 2 ]; then
  echo "Error: 2 parameters are required."
  exit 1
fi

if [ "$1" != "--upstream-version" ]; then
  echo "Error: First parameter needs to be --upstream-version."
  exit 1
fi

UPSTREAM_VERSION=$2
ORIG_TARBALL=`readlink -e ../`/Oracle_VM_VirtualBox_Extension_Pack-${UPSTREAM_VERSION}.vbox-extpack

ORGDIR=`pwd`

cd `dirname $ORIG_TARBALL`
if ! wget -O - http://download.virtualbox.org/virtualbox/$UPSTREAM_VERSION/SHA256SUMS | grep extpack | sha256sum -c --strict -; then
  echo "Error: checksum doesn't match."
  exit 1
fi
cd $ORGDIR

PACKAGE_NAME=`awk '/^Source: / { print $2 }' debian/control`

if [ -z "$PACKAGE_NAME" ]; then
  echo "Error: couldn't determine package name."
  exit 1
fi

TMP=`mktemp -d`

if [ -z "$TMP" ]; then
  echo "Error: couldn't create a tmp dir."
  exit 1
fi

trap 'rm -r $TMP' EXIT

mkdir $TMP/${PACKAGE_NAME}-$UPSTREAM_VERSION
mv $ORIG_TARBALL $TMP/${PACKAGE_NAME}-$UPSTREAM_VERSION/
cd $TMP
tar czf ${PACKAGE_NAME}_$UPSTREAM_VERSION.orig.tar.gz ${PACKAGE_NAME}-$UPSTREAM_VERSION
mv ${PACKAGE_NAME}_$UPSTREAM_VERSION.orig.tar.gz $ORGDIR/../
cd $ORGDIR
echo "Done, now you can run gbp import-orig ../${PACKAGE_NAME}_$UPSTREAM_VERSION.orig.tar.gz"
