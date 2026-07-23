fail()
{
	echo "$1" 1>&2
	exit 1
}

git diff-index --quiet HEAD -- || fail "Images must not be pushed with uncommitted changes!"

set -euo pipefail
TARGET_IMAGE_NAME=${TARGET_IMAGE_NAME:-matchalunatic/moonlight-embedded-packaging}

TAG_UNIQUE_ID=`git ls-tree HEAD | sha256sum | cut -c-16`

for flavor in rpi rpi64; do
  for distro in trixie bookworm; do
    ./build-image.sh $flavor $distro $TAG_UNIQUE_ID &
  done
  echo "Waiting for flavor $flavor to complete builds..." && wait && echo " done"
done

for flavor in rpi rpi64; do
	for distro in trixie bookworm; do
		docker push ${TARGET_IMAGE_NAME}:${flavor}-${distro}_$TAG_UNIQUE_ID &
	done
done
echo "waiting for all pushes to complete..." && wait && echo " done"
