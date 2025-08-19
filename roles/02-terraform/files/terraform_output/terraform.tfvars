user           = "administrator@vcenter.sivan.local"
password       = "SivanLand@13400"
vsphere_server = "vcenter.sivan.local"

# Defaults (used if a VM item doesn't override)
datacenter     = "zimafarda"
datastore      = "SSD - 223 - Server"
resource_pool  = "RS2"
template       = "ubuntu24-template"
network        = "VM Network"
disk_size      = 50

# Define multiple VMs
vms = [
  {
    name            = "vm1"
    cpus            = 3
    memory          = 4096
    cloud_init_file = "./cloud-init-dir/cloud-init-vm1.yml"
    disk_size       = 30
  },  {
    name            = "vm2"
    cpus            = 3
    memory          = 4096
    cloud_init_file = "./cloud-init-dir/cloud-init-vm2.yml"
    disk_size       = 30
  },  {
    name            = "vm3"
    cpus            = 3
    memory          = 4096
    cloud_init_file = "./cloud-init-dir/cloud-init-vm3.yml"
    disk_size       = 30
  },  {
    name            = "vm4"
    cpus            = 3
    memory          = 4096
    cloud_init_file = "./cloud-init-dir/cloud-init-vm4.yml"
    disk_size       = 30
  }]
