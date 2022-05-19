terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0.2"
    }
    vault = {
      source = "hashicorp/vault"
      version = "~> 3.5.0"
    }
  }
  backend "gcs" {
    bucket  = "foo-cloud-storage" ### Google cloud storage for remote state || Can use terraform cloud instead 
    prefix  = "terraform/state" ### State files location path
  }
}
provider "vault" {
  address = var.vault_addr
}
provider "vsphere" {
  vsphere_server = data.vault_generic_secret.vsphere_auth.data["hostname"]
  user = data.vault_generic_secret.vsphere_auth.data["username"]
  password = data.vault_generic_secret.vsphere_auth.data["password"]
}