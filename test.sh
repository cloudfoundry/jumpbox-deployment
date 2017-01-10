#!/bin/bash

set -eu

vars_store_prefix=/tmp/jumpbox-deployment-test

clean_tmp() {
  rm -f ${vars_store_prefix}.*
}

trap clean_tmp EXIT

echo "- AWS"
bosh interpolate jumpbox.yml --var-errs \
  -o aws/cpi.yml \
  --vars-store $(mktemp ${vars_store_prefix}.XXXXXX) \
  -v internal_cidr=test \
  -v internal_gw=test \
  -v internal_ip=test \
  -v external_ip=test \
  -v access_key_id=test \
  -v secret_access_key=test \
  -v az=test \
  -v region=test \
  -v default_key_name=test \
  -v default_security_groups=[test] \
  -v private_key=test \
  -v subnet_id=test \
  > /dev/null

echo "- GCP"
bosh interpolate jumpbox.yml --var-errs \
  -o gcp/cpi.yml \
  --vars-store $(mktemp ${vars_store_prefix}.XXXXXX) \
  -v internal_cidr=test \
  -v internal_gw=test \
  -v internal_ip=test \
  -v external_ip=test \
  -v service_account=test \
  -v gcp_credentials_json=test \
  -v project_id=test \
  -v zone=test \
  -v network=test \
  -v subnetwork=test \
  -v tags="[internal, no-ip]" \
  > /dev/null

echo "- Openstack"
bosh interpolate jumpbox.yml --var-errs \
  -o openstack/cpi.yml \
  --vars-store $(mktemp ${vars_store_prefix}.XXXXXX) \
  -v internal_cidr=test \
  -v internal_gw=test \
  -v internal_ip=test \
  -v external_ip=test \
  -v auth_url=test \
  -v az=test \
  -v default_key_name=test \
  -v default_security_groups=test \
  -v net_id=test \
  -v openstack_password=test \
  -v openstack_username=test \
  -v private_key=test \
  -v region=test \
  -v tenant=test \
  > /dev/null

echo "- vSphere"
bosh interpolate jumpbox.yml --var-errs \
  -o vsphere/cpi.yml \
  -o no-external-ip.yml \
  --vars-store $(mktemp ${vars_store_prefix}.XXXXXX) \
  -v internal_cidr=test \
  -v internal_gw=test \
  -v internal_ip=test \
  -v network_name=test \
  -v vcenter_dc=test \
  -v vcenter_ds=test \
  -v vcenter_ip=test \
  -v vcenter_user=test \
  -v vcenter_password=test \
  -v vcenter_templates=test \
  -v vcenter_vms=test \
  -v vcenter_disks=test \
  -v vcenter_cluster=test \
  > /dev/null
