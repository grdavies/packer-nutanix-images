packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "basic" {
  iso_urls                = [ var.iso_url, ]
  iso_checksum            = var.iso_checksum
  iso_checksum_type       = var.iso_checksum_type
  floppy_files            = var.floppy_files
  shutdown_command        = var.shutdown_command
  communicator            = "winrm"
  winrm_username          = var.communicator_username
  winrm_password          = var.communicator_password
  winrm_port              = var.communicator_port
  winrm_no_proxy          = true
  winrm_timeout           = var.communicator_timeout
  pause_before_connecting = var.communicator_pause
  boot_wait               = var.boot_wait
  headless                = true
  cpus                    = var.cpus
  memory                  = var.memory
  disk_size               = var.disk_size
  format                  = "qcow2"
  accelerator             = "kvm"
  disk_detect_zeroes      = "unmap"
  skip_compaction         = false
  disk_compression        = true
  vnc_bind_address        = "0.0.0.0"
}

build {
  # Create base OS images for further customization
  name = "stage1"

  sources = [
    "source.qemu.basic",
  ]

  # Post Processors
  post-processors {
    post-processor "checksum" {
      checksum_types      = [ "md5" ]
      keep_input_artifact = true
      output              = "stage${var.build_stage}/kvm/${source.name}/${var.os}-${var.os_ver}-${os_edition}-${os_install_type}-${source.name}.{{.ChecksumType}}.checksum"
    }

    post-processor "manifest" {
      output = "stage${var.build_stage}/kvm/${source.name}/manifest.json"
    }
  }
}