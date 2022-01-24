packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "basic-ntnx" {
  disk_image          = true
  iso_url             = "stage1/kvm/basic/${var.os}-${var.os_ver}-basic.qcow2"
  iso_checksum        = "file:stage1/kvm/basic/${var.os}-${var.os_ver}-basic.md5.checksum"
  output_directory    = "stage${var.build_stage}/kvm/${source.name}"
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
  vm_name             = "${var.os}-${var.os_ver}-${source.name}.qcow2"
  net_device          = "virtio-net"
  disk_interface      = "virtio"
  boot_wait           = "10s"
  headless            = true
  disk_detect_zeroes  = "unmap"
  skip_compaction     = false
  disk_compression    = true
}

source "qemu" "lvm-ntnx" {
  disk_image          = true
  iso_url             = "stage1/kvm/lvm/${var.os}-${var.os_ver}-lvm.qcow2"
  iso_checksum        = "file:stage1/kvm/lvm/${var.os}-${var.os_ver}-lvm.md5.checksum"
  output_directory    = "stage${var.build_stage}/kvm/${source.name}"
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
  vm_name             = "${var.os}-${var.os_ver}-${source.name}.qcow2"
  net_device          = "virtio-net"
  disk_interface      = "virtio"
  boot_wait           = "10s"
  headless            = true
  disk_detect_zeroes  = "unmap"
  skip_compaction     = false
  disk_compression    = true
}

build {
  # Create base OS images for further customization
  name = "stage2"

  sources = [
    "source.qemu.basic-ntnx",
    "source.qemu.lvm-ntnx",
  ]

  # Post Processors
  post-processors {
    post-processor "checksum" {
      checksum_types      = [ "md5" ]
      keep_input_artifact = true
      output              = "stage${var.build_stage}/kvm/${source.name}/${var.os}-${var.os_ver}-${source.name}.{{.ChecksumType}}.checksum"
    }

    #post-processor "manifest" {
    #  output = "stage${var.build_stage}/kvm/manifest.json"
    #}

  }

  ## Set Nutanix best practices
  provisioner "shell" {
    script = "scripts/nutanix/ntnx_disable_transparent_hugepage.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script = "scripts/nutanix/ntnx_grub2_mkconfig.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script = "scripts/nutanix/ntnx_iscsi_settings.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script = "scripts/nutanix/ntnx_kernel_settings.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script = "scripts/nutanix/ntnx_set_disk_timeout.sh"
    expect_disconnect   = false
  }
  # Cleanup network interface configurations
  provisioner "shell" {
    script = "scripts/nutanix/ntnx_set_max_sectors_kb.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script = "scripts/nutanix/ntnx_set_noop.sh"
    expect_disconnect   = false
  }
}
