#!/bin/bash -exu

create_cpi_names() {
  echo bosh-aws-cpi > cpi-aws/name
  echo bosh-azure-cpi > cpi-azure/name
  echo bosh-google-cpi > cpi-gcp/name
  echo bosh-openstack-cpi > cpi-openstack/name
  echo bosh-vsphere-cpi > cpi-vsphere/name
}

bump_cpi() {
  local IAAS=${1?"IaaS is required (e.g. aws, azure, gcp, openstack, vsphere)"}

  local RELEASE_NAME="$(cat cpi-${IAAS}/name)"
  local RELEASE_VERSION="$(cat cpi-${IAAS}/version)"
  local RELEASE_URL="https://bosh.io/d/github.com/cloudfoundry/${RELEASE_NAME}-release?v=$RELEASE_VERSION"
  local RELEASE_SHA="$(cat cpi-${IAAS}/sha1)"

  cat > /tmp/bump-cpi-ops.yml <<EOF
---
- type: replace
  path: /path=~1releases~1-/value
  value:
    name: ${RELEASE_NAME}
    url: ${RELEASE_URL}
    sha1: ${RELEASE_SHA}
EOF

  bosh interpolate -o /tmp/bump-cpi-ops.yml \
    jumpbox-deployment/${IAAS}/cpi.yml > /tmp/cpi.yml

  cp /tmp/cpi.yml jumpbox-deployment/${IAAS}/cpi.yml

  pushd jumpbox-deployment
    local changed="$(git diff --name-only | grep ${IAAS}/cpi.yml)"
    if [[ -n "${changed}" ]]; then

        git config user.email "cf-infrastructure@pivotal.io"
        git config user.name "cf-infra-bot"

        git add .
        git commit -m "Bump CPI ${IAAS} to ${RELEASE_VERSION}"

    fi
  popd
}

main() {
  local iaas_list=(aws azure gcp openstack vsphere)

  create_cpi_names

  for iaas in "${iaas_list[@]}"; do
    bump_cpi $iaas
  done

  cp -R jumpbox-deployment/. updated-jumpbox-deployment
}

main "$@"
