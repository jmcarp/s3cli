#!/usr/bin/env bash

set -e

source s3cli-src/ci/tasks/utils.sh


semver='1.2.3.4'
timestamp=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

pushd s3cli-src > /dev/null
  git_rev=`git rev-parse --short HEAD`
  version="${semver}-${git_rev}-${timestamp}"

  . .envrc

  echo -e "\n Vetting packages for potential issues..."
  go vet s3cli/...

  echo -e "\n Checking with golint..."
  golint s3cli/...

  echo -e "\n Unit testing packages..."
  ginkgo -r -race -skipPackage=integration src/s3cli/

  echo -e "\n Running build script to confirm everything compiles..."
  go build -ldflags "-X main.version ${version}" -o out/s3cli s3cli/s3cli

  echo -e "\n Testing version information"
  app_version=$(out/s3cli -v)
  test "${app_version}" = "version ${version}"

  echo -e "\n suite success"
popd > /dev/null
