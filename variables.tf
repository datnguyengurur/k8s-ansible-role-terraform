# vSphere Settings
variable "vsphere_datacenter" {
  type = string
  default = "Poseidon DC"
}
variable "vsphere_cluster" {
  type = string
  default = "Hermes CT"
}
variable "vsphere_server" {
  type = string
}
variable "vsphere_user" {
  type = string
  sensitive = true
}
variable "vsphere_password" {
  type = string
  sensitive = true
}

variable "cloudinit_users" {
    type = list(object(
      {
        username = string
        ssh_public_key = string
      }
    ))
    default = [
        {
            username = "ansible"
            ssh_public_key = "ssh-ed25519 ansible@ntdsecurity.com"
        },
        {
            username = "dat.nguyen"
            ssh_public_key = "ssh-ed25519 jason.nguyen@ntdsecurity.com"
        }
    ]
}

variable "vault_addr" {
  type = string
  default = "https://vault.api.intranet.ntdsecurity.com:8200"
}

variable "k8s_cluster_vip" {
  type = string
  default = "192.168.110.1"
}