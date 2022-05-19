data template_file "metadata" {
  template = file("templates/cloud-init/metadata.tftpl")
  vars = {
    dhcp        = "true"
    hostname    = "ubuntu"
    nameservers = jsonencode(["1.1.1.1", "1.0.0.1"])
  }
}
data template_file "userdata" {
  template = templatefile("templates/cloud-init/userdata.tftpl",{
      users = var.cloudinit_users
  })
}
