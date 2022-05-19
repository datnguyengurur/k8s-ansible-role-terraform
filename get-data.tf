data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}
data "vsphere_distributed_virtual_switch" "hikari_sw" {
  name = "Hikari"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_distributed_virtual_switch" "hiroshi_sw" {
  name = "Hiroshi"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "ubuntu_focal" {
  name          = "Templates/linux-ubuntu-20.04lts-v22.05"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "ubuntu_jammy" {
  name          = "Templates/linux-ubuntu-22.04lts-v22.05"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "vsanDatastore" {
  name          = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_cluster}/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "lan" {
    name = "DEFAULT-LAN"
    datacenter_id = data.vsphere_datacenter.dc.id
}