terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.0"
}

provider "vsphere" {
  user           = var.user
  password       = var.password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

# Common datacenter/datastore/resource-pool
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create per-VM template and network data sources so each vm can override
# the global template/network if desired.
# Keyed by VM name.
data "vsphere_virtual_machine" "template" {
  for_each     = { for vm in var.vms : vm.name => lookup(vm, "template", var.template) }
  name         = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net" {
  for_each     = { for vm in var.vms : vm.name => lookup(vm, "network", var.network) }
  name         = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create virtual machines (one resource per item in var.vms)
resource "vsphere_virtual_machine" "vm" {
  for_each = { for vm in var.vms : vm.name => vm }

  name             = each.value.name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  # accept numeric or string values in tfvars by coercing to string then to number
  num_cpus = tonumber(tostring(lookup(each.value, "cpus", 1)))
  memory   = tonumber(tostring(lookup(each.value, "memory", 1024)))
  guest_id = data.vsphere_virtual_machine.template[each.key].guest_id

  scsi_type = data.vsphere_virtual_machine.template[each.key].scsi_type

  network_interface {
    network_id   = data.vsphere_network.net[each.key].id
    adapter_type = data.vsphere_virtual_machine.template[each.key].network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = tonumber(tostring(lookup(each.value, "disk_size", var.disk_size)))
    eagerly_scrub    = data.vsphere_virtual_machine.template[each.key].disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template[each.key].disks[0].thin_provisioned
  }

  cdrom {
    client_device = true
  }

  vapp {
    properties = {
      hostname  = each.value.name
      user-data = base64encode(file(each.value.cloud_init_file))
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template[each.key].id
  }

  extra_config = {
    "tools.setPowerOn" = "TRUE"
  }
}

output "vm_ips" {
  description = "Map of VM name => IP address (default_ip_address). Note: IP available only after tools/guest nic up."
  value       = { for k, v in vsphere_virtual_machine.vm : k => v.default_ip_address }
}
