#!/usr/bin/env bash


set -euo pipefail
PLATFORM="$1"
DEBIAN_VERSION="$2"
TARGET_REF="${3:-master}"
TARGET_NAME="${PLATFORM}-${DEBIAN_VERSION}"
TARGET_IMAGE_NAME=${DOCKER_IMAGE_NAME:-matchalunatic/moonlight-embedded-packaging}
REPO_URL="${REPO_URL:-https://github.com/matchaxnb/moonlight-embedded.git}"
DEBFULLNAME=${DEBFULLNAME:-"Moonlight CI"}
DEBEMAIL=${DEBEMAIL:-ci@moonlight-stream.org}
TAG_UNIQUE_ID=`(git ls-tree HEAD; git diff-index HEAD) | sha256sum | cut -c-16`
TAG_NAME="${TARGET_NAME}_${TAG_UNIQUE_ID}"
OUT_DIR="out_$TARGET_NAME"

set +euo pipefail
docker pull matchalunatic/moonlight-embedded-packaging:$TAG_NAME
PULL_EXIT_CODE=$?
set -euo pipefail

rm -rf $OUT_DIR

set -e
mkdir $OUT_DIR

if [ $PULL_EXIT_CODE -eq 0 ]; then
  echo Using pre-built Docker image - $TARGET_IMAGE_NAME:$TAG_NAME
else
  echo Pre-built image not available - building ${TARGET_IMAGE_NAME}:$TAG_NAME
  ./build-image.sh $PLATFORM $DEBIAN_VERSION $TAG_UNIQUE_ID
  echo Built Docker image - ${TARGET_IMAGE_NAME}:$TAG_NAME
fi

docker run --rm --mount type=bind,source="$(pwd)"/$OUT_DIR,target=/out --mount type=bind,source="$(pwd)"/debian,target=/opt/debian -e COMMIT="${TARGET_REF}" -e REPO_URL="${REPO_URL}" -e DEBFULLNAME="${DEBFULLNAME}" -e DEBEMAIL="${DEBEMAIL}" $TARGET_IMAGE_NAME:$TAG_NAME

# Push the image now if we're building master in GitHub Actions
if [ $PULL_EXIT_CODE -ne 0 ] && [ "$GITHUB_REF" == "refs/heads/master" ]; then
  docker push $TARGET_IMAGE_NAME:$TAG_NAME
fi