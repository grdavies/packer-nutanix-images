packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "basic-ntnx-hardened" {
  disk_image          = true
  iso_url             = "stage2/kvm/basic-ntnx/${var.os}-${var.os_ver}-ntnx.qcow2"
  iso_checksum        = "file:stage2/kvm/basic-ntnx/${var.os}-${var.os_ver}-ntnx.md5.checksum"
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

source "qemu" "lvm-ntnx-hardened" {
  disk_image          = true
  iso_url             = "stage2/kvm/lvm-ntnx/${var.os}-${var.os_ver}-lvm-ntnx.qcow2"
  iso_checksum        = "file:stage2/kvm/lvm-ntnx/${var.os}-${var.os_ver}-lvm-ntnx.md5.checksum"
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
  name = "stage3"

  sources = [
    "source.qemu.basic-ntnx-hardened",
    "source.qemu.lvm-ntnx-hardened",
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

  # Run scripts to apply OS hardening
  provisioner "shell" {
    execute_command   = "sudo -E bash '{{ .Path }}'"
    scripts           = [
                          "scripts/centos/security_hardening_etckeeper.sh",
                          "scripts/centos/security_hardening_repos.sh",
                          "scripts/centos/security_hardening_pam.sh",
                          "scripts/centos/security_hardening_modprobe.sh",
                          "scripts/centos/security_hardening_modprobe.sh",
                          "scripts/centos/security_firewalld_enable.sh",
                          "scripts/centos/security_hardening_umask.sh",
                          "scripts/centos/security_hardening_fstab.sh",
                          "scripts/centos/security_hardening_passwords.sh",
                          "scripts/centos/security_hardening_tcp_wrappers.sh",
                          "scripts/centos/security_hardening_secure_tty.sh",
                          "scripts/centos/security_hardening_auditd.sh",
                          "scripts/centos/security_hardening_oscap.sh",
                          "scripts/centos/security_hardening_grub.sh",
                          "scripts/centos/security_hardening_crond.sh",
                          "scripts/centos/security_hardening_aide.sh",
                        ]
    expect_disconnect = false
  }
}
