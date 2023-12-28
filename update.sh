#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# BuildBot Master (currently Debian Bullseye as base)
update_image "buildbot/buildbot-master" "BuildBot Master" "true" "v(\d+\.)+\d+"
# Clean, semantic version tag
_NEXT_VERSION=${_NEXT_VERSION#v}

# Packages from pypi
update_pypi "pyOpenSSL" "Python OpenSSL" "false" "(\d+\.)+\d+"
update_pypi "service-identity" "Python Service-Identity" "false" "(\d+\.)+\d+"

if ! updates_available; then
	#echo "No updates available."
	exit 0
fi

if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi