#!/bin/bash -exu

create_stemcell_names() {
  echo bosh-aws-xen-hvm-ubuntu-xenial-go_agent > stemcell-aws/name
  echo bosh-azure-hyperv-ubuntu-trusty-go_agent > stemcell-azure/name
  echo bosh-google-kvm-ubuntu-xenial-go_agent > stemcell-gcp/name
  echo bosh-openstack-kvm-ubuntu-xenial-go_agent > stemcell-openstack/name
  echo bosh-vsphere-esxi-ubuntu-xenial-go_agent > stemcell-vsphere/name
}

bump_stemcell() {
  local IAAS=${1?"IaaS is required (e.g. aws, azure, gcp, openstack, vsphere)"}

  local STEMCELL_NAME="$(cat stemcell-${IAAS}/name)"
  local STEMCELL_VERSION="$(cat stemcell-${IAAS}/version)"
  local STEMCELL_URL="https://bosh.io/d/stemcells/$STEMCELL_NAME?v=$STEMCELL_VERSION"
  local STEMCELL_SHA="$(cat stemcell-${IAAS}/sha1)"

  cat > /tmp/bump-stemcell-ops.yml <<EOF
---
- type: replace
  path: /path=~1resource_pools~1name=vms~1stemcell??/value
  value:
    url: ${STEMCELL_URL}
    sha1: ${STEMCELL_SHA}
EOF

  bosh interpolate -o /tmp/bump-stemcell-ops.yml \
    jumpbox-deployment/${IAAS}/cpi.yml > /tmp/cpi.yml

  cp /tmp/cpi.yml jumpbox-deployment/${IAAS}/cpi.yml
}

main() {
  local STEMCELL_VERSION="$(cat stemcell-aws/version)"
  local iaas_list=(aws azure gcp openstack vsphere)

  create_stemcell_names

  for iaas in "${iaas_list[@]}"; do
    bump_stemcell $iaas
  done

  pushd jumpbox-deployment
    git config user.email "cf-infrastructure@pivotal.io"
    git config user.name "cf-infra-bot"

    git add .
    git commit -m "Bump stemcells to ${STEMCELL_VERSION}"
  popd

  cp -R jumpbox-deployment/. updated-jumpbox-deployment
}

main "$@"
