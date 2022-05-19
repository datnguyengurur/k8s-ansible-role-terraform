#!/bin/bash
echo $(vault kv get -field=ansible_encrypt_key kv/vmware/vsphere/inventory)