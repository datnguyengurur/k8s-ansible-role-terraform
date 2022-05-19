##################################
# CREATE TAGS FOR ANSIBLE GROUPS #
##################################

### NOTE pls use "_" to seperate words, "-" dose not work for ansible vmware plugin
resource "vsphere_tag" "k8s_dev_master_cluster" {
  name        = "k8s_dev_master_cluster"
  category_id = "${vsphere_tag_category.ansible_role_category.id}"
  description = "Managed by Terraform"
}
resource "vsphere_tag" "k8s_dev_loadbalancer_cluster" {
  name        = "k8s_dev_loadbalancer_cluster"
  category_id = "${vsphere_tag_category.ansible_role_category.id}"
  description = "Managed by Terraform"
}
resource "vsphere_tag" "k8s_dev_worker_cluster" {
  name        = "k8s_dev_worker_cluster"
  category_id = "${vsphere_tag_category.ansible_role_category.id}"
  description = "Managed by Terraform"
}
resource "vsphere_tag" "k8s_master_first_node" {
  name        = "k8s_master_first_node"
  category_id = "${vsphere_tag_category.ansible_role_category.id}"
  description = "Managed by Terraform"
}
resource "vsphere_tag" "k8s_dev_members" {
  name        = "k8s_dev_members"
  category_id = "${vsphere_tag_category.ansible_role_category.id}"
  description = "Managed by Terraform"
}
resource "vsphere_tag_category" "ansible_role_category" {
  name        = "ansible_role"
  cardinality = "MULTIPLE"
  description = "Managed by Terraform"
  associable_types = [
    "VirtualMachine",
  ]
}

#####################################
# CREATE VM FOR KUBERNESTES CLUSTER #
#####################################
resource "vsphere_virtual_machine" "k8s_dev_master_first_node" {
    folder = vsphere_folder.k8s_dev_folder.path
    name             = "k8s-dev-master-1"
    num_cpus         = 4
    memory           = 4096
    datastore_id     = data.vsphere_datastore.vsanDatastore.id
    resource_pool_id = data.vsphere_resource_pool.pool.id
    guest_id         = data.vsphere_virtual_machine.ubuntu_jammy.guest_id
    firmware         = data.vsphere_virtual_machine.ubuntu_jammy.firmware
    tags = ["${vsphere_tag.k8s_dev_master_cluster.id}","${vsphere_tag.k8s_dev_master_first_node.id}","${vsphere_tag.k8s_dev_members.id}"]
    network_interface {
        network_id = data.vsphere_network.lan.id
    }
    disk {
        label = "disk0.vmdk"
        size = "100"
        thin_provisioned = true
    }
    clone {
        template_uuid = data.vsphere_virtual_machine.ubuntu_jammy.id
    }
    provisioner "remote-exec" {
        inline = [
            "sudo hostnamectl set-hostname ${self.name}",
            "sudo growpart /dev/sda 3",
            "sudo pvresize /dev/sda3",
            "sudo lvextend -L +5G /dev/mapper/sysvg-root",
            "sudo lvextend -L +5G /dev/mapper/sysvg-opt",
            "sudo lvextend -L +5G /dev/mapper/sysvg-home",
            "sudo lvextend -L +5G /dev/mapper/sysvg-tmp",
            "sudo lvextend -L +5G /dev/mapper/sysvg-audit",
            "sudo lvextend -L +5G /dev/mapper/sysvg-log",
            "sudo lvextend --extents +100%FREE /dev/mapper/sysvg-var",
            "for p in root opt home tmp audit log var; do sudo xfs_growfs /dev/mapper/sysvg-$p; done", 
        ]
    }
    connection {
        type     = "ssh"
        user     = "ansible"
        private_key = file("~/.ssh/ansible")
        host     = self.default_ip_address
    }
    extra_config = {
        "guestinfo.metadata"          = base64encode(data.template_file.metadata.rendered)
        "guestinfo.metadata.encoding" = "base64"
        "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
        "guestinfo.userdata.encoding" = "base64"
    }
    provisioner "local-exec" {
        command = "ansible-playbook ${path.module}/ansible/debian-prep.yml"
        environment = {
            ANSIBLE_PRIVATE_KEY_FILE = "~/.ssh/ansible" 
            WORKING_HOST = "${self.name}"
        }
    }
    lifecycle {
        ignore_changes = [
        clone[0].template_uuid,
        annotation,
        ]
    }
}
resource "vsphere_virtual_machine" "k8s_dev_master" {
    count = 4
    folder = vsphere_folder.k8s_dev_folder.path
    name             = "k8s-dev-master-${2+count.index}"
    num_cpus         = 4
    memory           = 4096
    datastore_id     = data.vsphere_datastore.vsanDatastore.id
    resource_pool_id = data.vsphere_resource_pool.pool.id
    guest_id         = data.vsphere_virtual_machine.ubuntu_jammy.guest_id
    firmware         = data.vsphere_virtual_machine.ubuntu_jammy.firmware
    tags = ["${vsphere_tag.k8s_dev_master_cluster.id}","${vsphere_tag.k8s_dev_members.id}"]
    network_interface {
        network_id = data.vsphere_network.lan.id 
    }
    disk {
        label = "disk0.vmdk"
        size = "100"
        thin_provisioned = true
    }
    clone {
        template_uuid = data.vsphere_virtual_machine.ubuntu_jammy.id
    }
    provisioner "remote-exec" {
        inline = [
            "sudo hostnamectl set-hostname ${self.name}",
            "sudo growpart /dev/sda 3",
            "sudo pvresize /dev/sda3",
            "sudo lvextend -L +5G /dev/mapper/sysvg-root",
            "sudo lvextend -L +5G /dev/mapper/sysvg-opt",
            "sudo lvextend -L +5G /dev/mapper/sysvg-home",
            "sudo lvextend -L +5G /dev/mapper/sysvg-tmp",
            "sudo lvextend -L +5G /dev/mapper/sysvg-audit",
            "sudo lvextend -L +5G /dev/mapper/sysvg-log",
            "sudo lvextend --extents +100%FREE /dev/mapper/sysvg-var",
            "for p in root opt home tmp audit log var; do sudo xfs_growfs /dev/mapper/sysvg-$p; done", 
        ]
    }
    connection {
        type     = "ssh"
        user     = "ansible"
        private_key = file("~/.ssh/ansible")
        host     = self.default_ip_address
    }
    extra_config = {
        "guestinfo.metadata"          = base64encode(data.template_file.metadata.rendered)
        "guestinfo.metadata.encoding" = "base64"
        "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
        "guestinfo.userdata.encoding" = "base64"
    }
    provisioner "local-exec" {
        command = "ansible-playbook ${path.module}/ansible/debian-prep.yml"
        environment = {
            ANSIBLE_PRIVATE_KEY_FILE = "~/.ssh/ansible" 
            WORKING_HOST = "${self.name}"
        }
    }
    lifecycle {
        ignore_changes = [
        clone[0].template_uuid,
        annotation,
        ]
    }
}
resource "vsphere_virtual_machine" "k8s_dev_woker" {
    count = 6
    folder = vsphere_folder.k8s_dev_folder.path
    name             = "k8s-dev-worker-${1+count.index}"
    num_cpus         = 4
    memory           = 4096
    datastore_id     = data.vsphere_datastore.vsanDatastore.id
    resource_pool_id = data.vsphere_resource_pool.pool.id
    guest_id         = data.vsphere_virtual_machine.ubuntu_jammy.guest_id
    firmware         = data.vsphere_virtual_machine.ubuntu_jammy.firmware
    tags = ["${vsphere_tag.k8s_dev_worker_cluster.id}","${vsphere_tag.k8s_dev_members.id}"]
    network_interface {
        network_id = data.vsphere_network.lan.id
    }
    disk {
        label = "disk0.vmdk"
        size = "200"
        thin_provisioned = true
    }
    clone {
        template_uuid = data.vsphere_virtual_machine.ubuntu_jammy.id
    }
    provisioner "remote-exec" {
        inline = [
            "sudo hostnamectl set-hostname ${self.name}",
            "sudo growpart /dev/sda 3",
            "sudo pvresize /dev/sda3",
            "sudo lvextend -L +5G /dev/mapper/sysvg-root",
            "sudo lvextend -L +5G /dev/mapper/sysvg-opt",
            "sudo lvextend -L +5G /dev/mapper/sysvg-home",
            "sudo lvextend -L +5G /dev/mapper/sysvg-tmp",
            "sudo lvextend -L +5G /dev/mapper/sysvg-audit",
            "sudo lvextend -L +5G /dev/mapper/sysvg-log",
            "sudo lvextend --extents +100%FREE /dev/mapper/sysvg-var",
            "for p in root opt home tmp audit log var; do sudo xfs_growfs /dev/mapper/sysvg-$p; done", 
        ]
    }
    connection {
        type     = "ssh"
        user     = "ansible"
        private_key = file("~/.ssh/ansible")
        host     = self.default_ip_address
    }
    extra_config = {
        "guestinfo.metadata"          = base64encode(data.template_file.metadata.rendered)
        "guestinfo.metadata.encoding" = "base64"
        "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
        "guestinfo.userdata.encoding" = "base64"
    }
      provisioner "local-exec" {
        command = "ansible-playbook ${path.module}/ansible/debian-prep.yml"
        environment = {
            ANSIBLE_PRIVATE_KEY_FILE = "~/.ssh/ansible" 
            WORKING_HOST = "${self.name}"
        }
    }
    lifecycle {
        ignore_changes = [
        clone[0].template_uuid,
        annotation,
        ]
    }
}
resource "vsphere_virtual_machine" "k8s_dev_loadbalancer" {
    depends_on = [
      local_file.haproxy_ansible_playbook
    ]
    count = 3
    folder = vsphere_folder.k8s_dev_folder.path
    name             = "k8s-dev-lb-${1+count.index}"
    num_cpus         = 2
    memory           = 1024
    datastore_id     = data.vsphere_datastore.vsanDatastore.id
    resource_pool_id = data.vsphere_resource_pool.pool.id
    guest_id         = data.vsphere_virtual_machine.ubuntu_jammy.guest_id
    firmware         = data.vsphere_virtual_machine.ubuntu_jammy.firmware
    tags = ["${vsphere_tag.k8s_dev_loadbalancer_cluster.id}"]
    network_interface {
        network_id = data.vsphere_network.lan.id
    }
    disk {
        label = "disk0.vmdk"
        size = "40"
        thin_provisioned = true
    }
    clone {
        template_uuid = data.vsphere_virtual_machine.ubuntu_jammy.id
    }
    provisioner "remote-exec" {
        inline = [
            "sudo hostnamectl set-hostname ${self.name}",
        ]
    }
    connection {
        type     = "ssh"
        user     = "ansible"
        private_key = file("~/.ssh/ansible")
        host     = self.default_ip_address
    }
    extra_config = {
        "guestinfo.metadata"          = base64encode(data.template_file.metadata.rendered)
        "guestinfo.metadata.encoding" = "base64"
        "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
        "guestinfo.userdata.encoding" = "base64"
    }
     provisioner "local-exec" {
        command = "ansible-playbook ${local_file.haproxy_ansible_playbook.filename}"
        environment = {
            IS_MASTER = "${count.index}"
            ANSIBLE_PRIVATE_KEY_FILE = "~/.ssh/ansible"
            WORKING_HOST = "${self.name}" 
        }
    }
    lifecycle {
        ignore_changes = [
        clone[0].template_uuid,
        annotation,
        ]
    }
}

###########################
# CREATE ANSIBLE PLAYBOOK #
###########################
resource "local_file" "haproxy_ansible_playbook" {
    depends_on = [
    vsphere_virtual_machine.k8s_dev_master,
    vsphere_virtual_machine.k8s_dev_master_first_node
    ]
    file_permission = "0600"
    directory_permission = "0700"
    content = templatefile("templates/haproxy.tftpl",
        {
            ansible_roles = ["debian-prep","keepalived", "haproxy"]
            frontend_name = "k8s-dev-controlplane"
            frontend_port = "6443"
            bind_address = "0.0.0.0"
            backend_name = "k8s-dev-master-servers"
            backend_port = "6443"
            haproxy_instances = [
                {
                    name = "cluster-1" 
                    vip = var.k8s_cluster_vip # "192.168.110.240"
                    router_id = "20"
                    keepalived_password = "" # Sensitive variable, store it safe. Maybe create and store it from vault
                    interface_name = "ens192" 
                }
            ]
            backend_servers = concat(vsphere_virtual_machine.k8s_dev_master,[vsphere_virtual_machine.k8s_dev_master_first_node])
        }
    )
    filename = "ansible/haproxy_playbook.yml"
}

#### Should be remove when done or encrypt with ansible-vault
resource "local_file" "k8s_ansible_playbook" {
    depends_on = [
    vsphere_virtual_machine.k8s_dev_master,
    vsphere_virtual_machine.k8s_dev_master_first_node,
    vsphere_virtual_machine.k8s_dev_loadbalancer,
    ]
    file_permission = "0600"
    directory_permission = "0700"
    content = templatefile("templates/k8s.tftpl",
        {
            k8s_cluster_group = vsphere_tag.k8s_dev_members.name
            master_first_node_tag = vsphere_tag.k8s_master_first_node.name
            master_group_tag = vsphere_tag.k8s_dev_master_cluster.name
            worker_group_tag = vsphere_tag.k8s_dev_worker_cluster.name
            certificate_key = "" # f898771546fd9a877f01b1494ca2a3790a6113eebdbf669e34245949137650c4
            # Certificate Key is sensitive variable, store it safe. Maybe create and store it from vault
            # Create by running the command "kubeadm certs certificate-key"
            longhorn_version = "" # v1.2.4 
            control_plane_endpoint = "${var.k8s_cluster_vip}:6443" 
            pod_network_cni = "calico"
            pod_network_cidr = "10.250.0.0/16" # Not yet work
        }
    )
    filename = "ansible/k8s_playbook.yml"
}

############################
# RUN K8S ANSIBLE PLAYBOOK #
############################
#### Rerun when add more nodes or masters (destroy and recreate)
resource "null_resource" "run_ansible_playbook_to_install_k8s_cluster" {
    count = length(vsphere_virtual_machine.k8s-worker.*)
    depends_on = [local_file.k8s_ansible_playbook]
    provisioner "local-exec" {
        command = "ansible-playbook ${local_file.k8s_ansible_playbook.filename}"
    }
}