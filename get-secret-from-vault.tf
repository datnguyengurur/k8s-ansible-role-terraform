data "vault_generic_secret" "vsphere_auth" {
  path = "kv/vmware/vsphere/super-admin"
}
data "vault_generic_secret" "ad_auth" {
  path = "kv/ad/domain-admin"
}