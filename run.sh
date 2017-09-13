#!/bin/bash

npm_setup() {
  if [ -z "${NPM_TOKEN}" ]; then
    fail 'Please specify auth token'
    exit 1
  fi

  if [ -n "${WERCKER_CACHE_DIR}" ]; then
    npm config set cache "$WERCKER_CACHE_DIR/wercker/npm"
  fi
}

npm_login() {
  echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc

  local retries=3;
  for try in $(seq "$retries"); do
    info "Starting npm whoami, try: $try"
    npm whoami && return
  done

  fail "Failed to authenticate with npm, retries: $retries"
  exit 1
}

npm_publish() {
  NPM_VERSION=$(grep package.json -e 'version' | awk '{print substr($2, 2, length($2)-3)}')
  NPM_VERSION_PRERELEASE=$(echo "${NPM_VERSION}" | cut -d '-' -f 2 -s)

  info "NPM_VERSION=${NPM_VERSION}"
  info "NPM_VERSION_PRERELEASE=${NPM_VERSION_PRERELEASE}"

  retries=3

  for try in $(seq "$retries"); do
    info "try: ${try}"
    npm publish --unsafe-perm
  done

  fail "npm publish failed with status code $?"
  exit 1
}

main() {
  npm_setup
  set +e
  npm_login
  npm_publish
  set -e

  success "Package successfully published to NPM"
}

main;
