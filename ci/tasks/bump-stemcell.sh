#!/bin/bash -exu

main() {
  local STEMCELL_URL="$(cat stemcell/url)"
  local STEMCELL_SHA="$(cat stemcell/sha1)"
  local STEMCELL_VERSION="$(cat stemcell/version)"

  pushd jumpbox-deployment
    cat > /tmp/bump-stemcell-ops.yml <<EOF
---
- type: replace
  path: /path=~1resource_pools~1name=vms~1stemcell??/value
  value:
    url: ${STEMCELL_URL}
    sha1: ${STEMCELL_SHA}
EOF

    bosh interpolate -o /tmp/bump-stemcell-ops.yml \
      ${IAAS}/cpi.yml > /tmp/cpi.yml

    cp /tmp/cpi.yml ${IAAS}/cpi.yml

    git config user.email "cf-infrastructure@pivotal.io"
    git config user.name "cf-infra-bot"

    git add ${IAAS}/cpi.yml
    git commit -m "Bump ${IAAS} Stemcell to ${STEMCELL_VERSION}"
  popd

  cp -R jumpbox-deployment/. updated-jumpbox-deployment
}

main "$@"
