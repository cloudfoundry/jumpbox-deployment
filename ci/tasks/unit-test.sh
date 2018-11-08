#!/bin/bash -exu

main() {
  export PROJECT_DIR=$PWD/jumpbox-deployment
  jumpbox-deployment/scripts/test
}

main "$@"
