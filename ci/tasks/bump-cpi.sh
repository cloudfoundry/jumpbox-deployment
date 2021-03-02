#!/usr/bin/env bash

set -euo pipefail

function bump_cpi() {
  local iaas=${1}
  local task_dir="${2}"
  local release_name
  local release_sha
  local release_url
  local release_version

  echo "Checking to see if ${iaas} CPI needs to be bumped..."

  release_name="$(basename "$(cat "${task_dir}/cpi-${iaas}/url")" | sed 's/^\(.*\)-release\?.*$/\1/')"
  release_sha="$(cat "${task_dir}/cpi-${iaas}/sha1")"
  release_url="$(cat "${task_dir}/cpi-${iaas}/url")"
  release_version="$(cat "${task_dir}/cpi-${iaas}/version")"

  cat > /tmp/bump-cpi-ops.yml <<EOF
---
- type: replace
  path: /path=~1releases~1-/value
  value:
    name: ${release_name}
    url: ${release_url}
    sha1: ${release_sha}
EOF

  bosh interpolate -o /tmp/bump-cpi-ops.yml \
    "${iaas}/cpi.yml" > /tmp/cpi.yml

  mv /tmp/cpi.yml "${iaas}/cpi.yml"

  local changed=""
  set +e
  changed="$(git diff --name-only | grep "${iaas}/cpi.yml")"
  set -e

  if [[ -n "${changed}" ]]; then
    git diff "${iaas}/cpi.yml"

    git config user.email "cf-infrastructure@pivotal.io"
    git config user.name "cf-infra-bot"

    git add .
    git commit -m "Bump ${iaas} CPI to ${release_version}"
  fi
}

function main() {
  local iaas_list=(aws azure gcp openstack vsphere)
  local task_dir="${1}"

  pushd jumpbox-deployment
    for iaas in "${iaas_list[@]}"; do
      bump_cpi "${iaas}" "${task_dir}"
      echo
    done
  popd

  cp -R jumpbox-deployment/. updated-jumpbox-deployment
}

main "${PWD}"
