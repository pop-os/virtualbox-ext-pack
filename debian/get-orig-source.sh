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

PACKAGE_NAME=`awk '/^Source: / { print $2 }' debian/control`

if [ -z "${PACKAGE_NAME}" ]; then
  echo "Error: couldn't determine package name."
  exit 1
fi

mkdir ${PACKAGE_NAME}_${UPSTREAM_VERSION}
tar cJvf ${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.xz ${PACKAGE_NAME}_${UPSTREAM_VERSION}
rm -rf ${PACKAGE_NAME}_${UPSTREAM_VERSION}
mv ${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.xz ..

echo "Done, now you can run:"
echo "gbp import-orig ../${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.xz"
