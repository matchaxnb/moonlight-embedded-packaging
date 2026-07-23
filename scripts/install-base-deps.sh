set -e
export DEBIAN_FRONTEND=noninteractive
apt-get -qq update
apt-get -qq install -y curl g++ make devscripts fakeroot debhelper git nasm libssl-dev libopus-dev libasound2-dev libudev-dev libavahi-client-dev libcurl4-openssl-dev libevdev-dev libexpat1-dev libpulse-dev uuid-dev libenet-dev libcec-dev cmake quilt libp8-platform-dev libdrm-dev libegl1-mesa-dev libgles2-mesa-dev libv4l-dev libsdl2-dev libavcodec-dev libavutil-dev
