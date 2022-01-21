packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "stage1_basic_partitions" {
  iso_url             = var.iso_url
  iso_checksum        = "file:${var.iso_checksum_url}"
  output_directory   = "stage1/kvm"
  cpus                = var.cpus
  memory              = var.memory
  shutdown_command    = var.shutdown_command
  disk_size           = var.disk_size
  format              = "qcow2"
  accelerator         = "kvm"
  http_directory      = "http"
  ssh_username        = "root"
  ssh_password        = "nutanix/4u"
  ssh_timeout         = "60m"
  vm_name             = "stage1_basic_partitions.qcow2"
  net_device          = "virtio-net"
  disk_interface      = "virtio"
  boot_wait           = "10s"
  boot_command        = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7.9-ahv-x86_64.cfg<enter><wait>"]
  headless            = true
  disk_detect_zeroes  = "unmap"
  skip_compaction     = false
  disk_compression    = true
  vnc_bind_address    = "0.0.0.0"
}

source "qemu" "stage1_lvm_partitions" {
  iso_url             = var.iso_url
  iso_checksum        = "file:${var.iso_checksum_url}"
  output_directory   = "stage1/kvm"
  cpus                = var.cpus
  memory              = var.memory
  shutdown_command    = var.shutdown_command
  disk_size           = var.disk_size
  format              = "qcow2"
  accelerator         = "kvm"
  http_directory      = "http"
  ssh_username        = "root"
  ssh_password        = "nutanix/4u"
  ssh_timeout         = "60m"
  vm_name             = "stage1_lvm_partitions.qcow2"
  net_device          = "virtio-net"
  disk_interface      = "virtio"
  boot_wait           = "10s"
  boot_command        = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7.9-ahv-x86_64-lvm.cfg<enter><wait>"]
  headless            = true
  disk_detect_zeroes  = "unmap"
  skip_compaction     = false
  disk_compression    = true
  vnc_bind_address    = "0.0.0.0"
}

build {
  # Create base OS images for further customization
  name = "stage1-base-images"

  sources = [
    "source.qemu.stage1_basic_partitions",
    "source.qemu.stage1_lvm_partitions",
  ]

  # Post Processors
  post-processors {
    post-processor "checksum" {
      checksum_types      = [ "md5" ]
      keep_input_artifact = true
      output              = "stage1/kvm/${source.name}.{{.ChecksumType}}.checksum"
    }
    
    post-processor "manifest" {
      output = "stage1/kvm/manifest.json"
    }

  }

  # Run updates
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/centos/security_updates.sh",
                         ]
    expect_disconnect  = false
  }

  # Run install packages
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/centos/security_updates.sh",
                          "scripts/centos/packages_yum_tools.sh",
                          "scripts/centos/packages_net_tools.sh",
                          "scripts/centos/packages_cloud_init.sh",
                         ]
    expect_disconnect  = false
  }
}
