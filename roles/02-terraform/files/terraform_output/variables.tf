# vCenter connection
variable "user" {}
variable "password" {}
variable "vsphere_server" {}

# vCenter topology defaults
variable "datacenter" {}
variable "datastore" {}
variable "resource_pool" {}
variable "template" {}
variable "network" {}

# Default disk size (used when per-VM disk_size omitted)
variable "disk_size" {
  type    = number
  default = 50
}

# Primary new variable: list of VMs to create.
# Each item is a map with keys:
#   name (required)
#   cpus (number or string, e.g. 2 or "2")
#   memory (MB) (number or string)
#   cloud_init_file (path to cloud-init YAML)
# Optional per-VM overrides:
#   disk_size, template, network
variable "vms" {
  type        = list(map(any))
  description = "List of VM definitions. Each map must include 'name', 'cpus', 'memory', and 'cloud_init_file'. Optional: disk_size, template, network."
  default     = []
}
