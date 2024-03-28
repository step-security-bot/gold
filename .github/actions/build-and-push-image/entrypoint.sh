#! /bin/bash
# shellcheck disable=SC2154

docker login ghcr.io -u "${GITHUB_ACTOR}" --password "${ACCESS_TOKEN}"
#
# Build and push image
#
figlet "Build ${IMAGE_NAME}"
make "${IMAGE_NAME}"
figlet "Push ${IMAGE_NAME}"
make "${IMAGE_NAME}-push"
