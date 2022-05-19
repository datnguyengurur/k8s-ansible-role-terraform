#!/bin/zsh
kubeadm certs certificate-key

ansible-vault encrypt ansible/inventory-vmware.yml



#### Install dependencies for vmare python sdk
pip3 install --upgrade pip setuptools
pip3 install --upgrade virtualenv
pip3 install --upgrade git+https://github.com/vmware/vsphere-automation-sdk-python.git
pip3 install requests[security]
pip3 install pyopenssl ndg-httpsclient pyasn1
pip3 install pyvmomi



ansible-galaxy collection install community.vmware