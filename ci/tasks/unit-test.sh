#!/usr/bin/env bash

set -euo pipefail

function main() {
  local task_dir="${1}"

  export PROJECT_DIR="${task_dir}/jumpbox-deployment"
  jumpbox-deployment/scripts/test
}

main "${PWD}"
