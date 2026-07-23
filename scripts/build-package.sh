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

if [ -x scripts/version.sh ]; then
  FULL_VERSION=$(bash scripts/version.sh)
else
  FULL_VERSION=$(grep project\( CMakeLists.txt | cut -d ' ' -f 3)
fi
# Debian package version must be major.minor.patch (no tweak component)
DEB_VERSION=$(echo "$FULL_VERSION" | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+')

mkdir /opt/build
/opt/scripts/git-archive-all.sh --format tar.gz /opt/build/moonlight-embedded_$FULL_VERSION.orig.tar.gz

cd /opt/build
mkdir moonlight-embedded-$FULL_VERSION
cd moonlight-embedded-$FULL_VERSION
tar xf ../moonlight-embedded_$FULL_VERSION.orig.tar.gz

cp -r /opt/debian .
cd debian
sed -i "s/^Maintainer:.*/Maintainer: ${DEBFULLNAME} <${DEBEMAIL}>/" control
dch -v "${DEB_VERSION}-1" "New upstream release ${DEB_VERSION}"
cd ..

DEB_BUILD_OPTIONS=terse debuild -us -uc 2>&1 | grep -v -E '^(dh_|make\[|make:.*Entering|make:.*Leaving|/usr/bin/cmake|cd obj-|cmake |gmake|gcc |g\+\+ )' | cat

cd /opt/build
shopt -s extglob
cp -v -r !(moonlight-embedded-$FULL_VERSION) /out

echo "Build successful!"
