#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh

# Error codes
DOCKER_UNAVAILABLE=1
UNKNOWN_TASK=2

# Check access to docker daemon
assert_dependency "docker"
if ! docker version &> /dev/null; then
	echo "Docker daemon is not running or you have unsufficient permissions!"
	exit "$DOCKER_UNAVAILABLE"
fi

docker build .
IMG_ID=$(docker build -q .)
IMG_NAME="buildbot-master"
IMG_REPO="hetsh"

TASK="${1-}"
case "$TASK" in
	# Assign production-tags
	"--tag")
		VERSION="$(git describe --tags --abbrev=0)"
		docker tag "$IMG_ID" "$IMG_NAME"
		docker tag "$IMG_ID" "$IMG_NAME:$VERSION"
	;;
	# Test with default configuration
	"--test")
		docker run \
			--rm \
			--tty \
			--interactive \
			--publish 8010:8010/tcp \
			--publish 9989:9989/tcp \
			--volume /etc/localtime:/etc/localtime:ro \
			"$IMG_ID"
	;;
	# Push image with production-tags, delete local ones
	"--upload")
		LATEST_TAG="$IMG_REPO/$IMG_NAME:latest"
		docker tag "$IMG_ID" "$LATEST_TAG"
		docker push "$LATEST_TAG"

		VERSION="$(git describe --tags --abbrev=0)"
		VERSION_TAG="$IMG_REPO/$IMG_NAME:$VERSION"
		docker tag "$IMG_ID" "$VERSION_TAG"
		docker push "$VERSION_TAG"

		docker image rm "$LATEST_TAG"
		docker image rm "$VERSION_TAG"
	;;
	# Print temporary tag disclaimer
	"")
		echo "Build successful!"
		echo "The image has not been tagged!"
		echo "Use the image ID instead: $IMG_ID"
	;;
	# Catch and notify about unkown task
	*)
		echo "Unknown task \"$TASK\"!"
		exit $UNKNOWN_TASK
	;;
esac
