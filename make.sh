#!/bin/bash

set -ue -o pipefail
if [ "${DEBUG-}" == "true" ]; then
  set -x
fi

CONTAINER_REGISTRY="ghcr.io"
# Repo is part of the image name for this build (repo=repository)
REPO=${GITHUB_REPOSITORY-unset}
# Tag is the image tag of this build's docker file
TAG=${TAG-${GITHUB_SHA-latest}}
# The docker image is the repository and tag together
IMAGE=${IMAGE-"${CONTAINER_REGISTRY}/${REPO}:${TAG}"}
X=hello

function build_docker() {
    docker build -t "${IMAGE}" .
}

function docker_tags() {
  echo "${CONTAINER_REGISTRY}/${GITHUB_REPOSITORY}:${GITHUB_SHA}"
  if [[ ${GITHUB_REF} =~ refs/tags/ ]]; then
    tag=${GITHUB_REF/refs\/tags\//}
    if [[ ${tag} == v* ]]; then
      tag=${tag:1}
    fi
    echo "${CONTAINER_REGISTRY}/${GITHUB_REPOSITORY}:${tag}"
  fi
  if [[ ${GITHUB_REF} == refs/heads/master ]]; then
    echo "${CONTAINER_REGISTRY}/${GITHUB_REPOSITORY}:latest"
    tag=${GITHUB_REF/refs\/heads\//}
    tag=${tag//\//-}
    echo "${CONTAINER_REGISTRY}/${GITHUB_REPOSITORY}:master-$(date -u +"%Y%m%dT%H%M%SZ")-$(echo "${GITHUB_SHA}" | cut -c -7)"
  fi
}

function lint() {
  hadolint ./Dockerfile
}

function push_images() {
  docker push "${IMAGE}"
  IFS=$'\n'       # make newlines the only separator
  for TAG in $(docker_tags); do
    echo "Making tag ${TAG}"
    docker tag "${IMAGE}" "${TAG}"
    docker push "${TAG}"
  done
}

declare -a funcs=(build_docker lint push_images)
for f in "${funcs[@]}"; do
  if [ "${f}" == "${1-}" ]; then
    $f "${@:2}"
    exit $?
  fi
done
echo "Invalid param ${1-}.  Valid options: ${funcs[*]}"
exit 1
