#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/matchaxnb/moonlight-embedded.git}"
COMMIT="${COMMIT:-master}"
DEBFULLNAME=${DEBFULLNAME:-"Moonlight CI"}
DEBEMAIL=${DEBEMAIL:-ci@moonlight-stream.org}

git clone --quiet $REPO_URL
cd moonlight-embedded
git checkout --quiet $COMMIT
git submodule update --quiet --init --recursive

VERSION=$(grep project\( CMakeLists.txt | cut -d ' ' -f 3)

mkdir /opt/build
/opt/scripts/git-archive-all.sh --format tar.gz /opt/build/moonlight-embedded_$VERSION.orig.tar.gz

cd /opt/build
mkdir moonlight-embedded-$VERSION
cd moonlight-embedded-$VERSION
tar xf ../moonlight-embedded_$VERSION.orig.tar.gz

cp -r /opt/debian .
cd debian
sed -i "s/^Maintainer:.*/Maintainer: ${DEBFULLNAME} <${DEBEMAIL}>/" control
dch -v "${VERSION}-1" "New upstream release ${VERSION}"
cd ..

DEB_BUILD_OPTIONS=terse debuild -us -uc 2>&1 | grep -v -E '^(dh_|make\[|make:.*Entering|make:.*Leaving|/usr/bin/cmake|cd obj-|cmake |gmake|gcc |g\+\+ )' | cat

cd /opt/build
shopt -s extglob
cp -v -r !(moonlight-embedded-$VERSION) /out

echo "Build successful!"
