packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "basic-ntnx-template" {
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

source "qemu" "basic-ntnx-hardened-template" {
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

source "qemu" "lvm-ntnx-template" {
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

source "qemu" "lvm-ntnx-hardened-template" {
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
  name = "stage99"

  sources = [
    "source.qemu.basic-ntnx-template",
    "source.qemu.lvm-ntnx-template",
    "source.qemu.basic-ntnx-hardened-template",
    "source.qemu.lvm-ntnx-hardened-template",
  ]

  # Post Processors
  post-processors {
    post-processor "checksum" {
      checksum_types      = [ "md5" ]
      keep_input_artifact = true
      output              = "stage${var.build_stage}/kvm/${source.name}/${var.os}-${var.os_ver}-${source.name}.{{.ChecksumType}}.checksum"
    }
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


  ## Security Hardening
  provisioner "shell" {
    script = "scripts/centos/security_hardening_etckeeper.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_repos.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_pam.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_modprobe.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_firewalld_enable.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_umask.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_fstab.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_passwords.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_tcp_wrappers.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_secure_tty.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_auditd.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_oscap.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_grub.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_crond.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }
  provisioner "shell" {
    script = "scripts/centos/security_hardening_aide.sh"
    expect_disconnect   = false
    only = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template", ]
  }


  ## Run scripts to prepare to seal the OS image
  provisioner "shell" {
    script = "scripts/linux-common/cleanup-network.sh"
    expect_disconnect   = true
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-dhcp-client-state.sh"
    expect_disconnect   = true
  }
  provisioner "shell" {
    script              = "scripts/linux-common/cleanup-disk-space.sh"
    expect_disconnect   = false
    timeout             = "1h"
  }
  provisioner "shell" {
    script              = "scripts/linux-common/cleanup-rpm-db.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-common/cleanup-network.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/centos/security_hardening_sshd.sh"
    expect_disconnect   = true
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-cloud-init.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-common/get_cloud-init_config.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-crash-data.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-firewall-rules.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/centos/security_selinux_set_enforcing.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-machine-id.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-package-manager-cache.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-package-manager-db.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-ssh-hostkeys.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-yum-uuid.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-tmp-files.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script = "scripts/linux-sysprep/sysprep-op-logfiles.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script = "scripts/linux-sysprep/sysprep-op-bash-history.sh"
    expect_disconnect   = false
  }
  provisioner "shell" {
    script = "scripts/linux-common/reset-root-password.sh"
    expect_disconnect   = false
  }
}
