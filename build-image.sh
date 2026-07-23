#!/usr/bin/env bash

set -euo pipefail
ENABLE_DEBUG="${ENABLE_DEBUG:-0}"
PLATFORM="$1"
DEBIAN_VERSION="$2"
DOCKERFILE="Dockerfile"
TARGET_IMAGE_NAME=${TARGET_IMAGE_NAME:-matchalunatic/moonlight-embedded-packaging}
BASE_IMAGE="arm32v7/debian"
TARGET_FLAVOR="rpi"
IMGTAG="$3"

EXTRA_ARGS="--pull"
if [ "$PLATFORM" == "aarch64" ] || [ "$PLATFORM" == "rpi64" ] || [ "$PLATFORM" == "l4t" ]; then
  EXTRA_ARGS="$EXTRA_ARGS --platform linux/arm64"
  BASE_IMAGE="arm64v8/debian"
  TARGET_FLAVOR="rpi64"
elif [ "$PLATFORM" == "armhf" ] || [ "$PLATFORM" == "rpi" ]; then
  EXTRA_ARGS="$EXTRA_ARGS --platform linux/arm/v7"
  BASE_IMAGE="arm32v7/debian"
  TARGET_FLAVOR="rpi"
elif [ "$PLATFORM" == "riscv64" ]; then
  EXTRA_ARGS="$EXTRA_ARGS --platform linux/riscv64"
  TARGET_FLAVOR="riscv64"
fi
if [ "$ENABLE_DEBUG" = "1" ]; then
  EXTRA_ARGS="$EXTRA_ARGS --debug"
fi

docker buildx build $EXTRA_ARGS -f $DOCKERFILE --build-arg DEBIAN_VERSION=${DEBIAN_VERSION} --build-arg ARCH_BASE_IMAGE=${BASE_IMAGE} --build-arg TARGET=${TARGET_FLAVOR} -t ${TARGET_IMAGE_NAME}:"${PLATFORM}-${DEBIAN_VERSION}_${IMGTAG}" .
