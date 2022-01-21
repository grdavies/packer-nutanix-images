packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "centos-basic-partitioning" {
  iso_url             = var.iso_url
  iso_checksum        = "file:${var.iso_checksum_url}"
  output_directory    = "output/${var.os}-${var.os_ver}-x86_64"
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
  vm_name             = "${var.os}-${var.os_ver}-x86_64.qcow2"
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

source "qemu" "centos-lvm-partitioning" {
  iso_url             = var.iso_url
  iso_checksum        = "file:${var.iso_checksum_url}"
  output_directory    = "output/${var.os}-${var.os_ver}-x86_64-lvm"
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
  vm_name             = "${var.os}-${var.os_ver}-x86_64-lvm"
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
  name = "step1-base-images"

  sources = [
    "source.qemu.centos-basic-partitioning",
    "source.qemu.centos-lvm-partitioning",
  ]

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

build {
  # Create base OS images for further customization
  name = "step2-ntnx-centos-basic"

  source "centos-basic-partitioning" {
    type                = "qemu"
    disk_image          = true
    iso_url             = "output/ntnx-${var.os}-${var.os_ver}-x86_64.qcow2"
    output_directory    = "output/ntnx-${var.os}-${var.os_ver}-ahv-x86_64"
    cpus                = var.cpus
    memory              = var.memory
    shutdown_command    = var.shutdown_command
    format              = "qcow2"
    accelerator         = "kvm"
    http_directory      = "http"
    ssh_username        = "root"
    ssh_password        = "nutanix/4u"
    ssh_timeout         = "60m"
    vm_name             = "ntnx-${var.os}-${var.os_ver}-ahv-x86_64.qcow2"
    net_device          = "virtio-net"
    disk_interface      = "virtio"
    boot_wait           = "10s"
    headless            = true
    disk_detect_zeroes  = "unmap"
    skip_compaction     = false
    disk_compression    = true
  }

  # Run scripts to apply Nutanix best practices
  provisioner "shell" {
    execute_command   = "sudo -E bash '{{ .Path }}'"
    scripts           = [
                          "centos/scripts/nutanix/ntnx_disable_transparent_hugepage.sh",
                          "centos/scripts/nutanix/ntnx_grub2_mkconfig.sh",
                          "centos/scripts/nutanix/ntnx_iscsi_settings.sh",
                          "centos/scripts/nutanix/ntnx_kernel_settings.sh",
                          "centos/scripts/nutanix/ntnx_set_disk_timeout.sh",
                          "centos/scripts/nutanix/ntnx_set_max_sectors_kb.sh",
                          "centos/scripts/nutanix/ntnx_set_noop.sh",
                        ]
    expect_disconnect = false
  }

  # Run scripts to apply OS hardening
  provisioner "shell" {
    execute_command   = "sudo -E bash '{{ .Path }}'"
    scripts           = [
                          "centos/scripts/centos/security_hardening_etckeeper.sh",
                          "centos/scripts/centos/security_hardening_repos.sh",
                          "centos/scripts/centos/security_hardening_pam.sh",
                          "centos/scripts/centos/security_hardening_modprobe.sh",
                          "centos/scripts/centos/security_hardening_modprobe.sh",
                          "centos/scripts/centos/security_firewalld_enable.sh",
                          "centos/scripts/centos/security_hardening_umask.sh",
                          "centos/scripts/centos/security_hardening_fstab.sh",
                          "centos/scripts/centos/security_hardening_passwords.sh",
                          "centos/scripts/centos/security_hardening_tcp_wrappers.sh",
                          "centos/scripts/centos/security_hardening_secure_tty.sh",
                          "centos/scripts/centos/security_hardening_auditd.sh",
                          "centos/scripts/centos/security_hardening_oscap.sh",
                          "centos/scripts/centos/security_hardening_grub.sh",
                          "centos/scripts/centos/security_hardening_crond.sh",
                          "centos/scripts/centos/security_hardening_aide.sh",
                        ]
    expect_disconnect = false
  }

  # Run scripts to prepare to seal the OS image
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/linux-common/cleanup-network.sh",
                          "scripts/linux-sysprep/sysprep-op-dhcp-client-state.sh",
                         ]
    expect_disconnect  = true
  }
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/linux-common/cleanup-disk-space.sh",
                          "scripts/linux-common/cleanup-rpm-db.sh",
                          "scripts/linux-common/get_cloud-init_config.sh",
                          "scripts/linux-common/cleanup-network.sh",
                          "scripts/centos/security_hardening_sshd.sh",
                          "scripts/linux-sysprep/sysprep-op-cloud-init.sh",
                          "scripts/linux-sysprep/sysprep-op-crash-data.sh",
                          "scripts/linux-sysprep/sysprep-op-firewall-rules.sh",
                          "scripts/centos/security_selinux_set_enforcing.sh",
                          "scripts/linux-sysprep/sysprep-op-machine-id.sh",
                          "scripts/linux-sysprep/sysprep-op-package-manager-cache.sh",
                          "scripts/linux-sysprep/sysprep-op-package-manager-db.sh",
                          "scripts/linux-sysprep/sysprep-op-ssh-hostkeys.sh",
                          "scripts/linux-sysprep/sysprep-op-yum-uuid.sh",
                          "scripts/linux-sysprep/sysprep-op-tmp-files.sh",
                          "scripts/linux-sysprep/sysprep-op-logfiles.sh",
                          "scripts/linux-sysprep/sysprep-op-bash-history.sh",
                          "scripts/linux-common/reset-root-password.sh",
                         ]
    expect_disconnect  = false
  }
}

build {
  # Create base OS images for further customization
  name = "step2-ntnx-centos-lvm"

  source "centos-basic-partitioning" {
    type                = "qemu"
    disk_image          = true
    iso_url             = "output/${var.os}-${var.os_ver}-x86_64-lvm.qcow2"
    output_directory    = "output/ntnx-${var.os}-${var.os_ver}-ahv-x86_64-lvm"
    cpus                = var.cpus
    memory              = var.memory
    shutdown_command    = var.shutdown_command
    format              = "qcow2"
    accelerator         = "kvm"
    http_directory      = "http"
    ssh_username        = "root"
    ssh_password        = "nutanix/4u"
    ssh_timeout         = "60m"
    vm_name             = "ntnx-${var.os}-${var.os_ver}-ahv-x86_64.qcow2"
    net_device          = "virtio-net"
    disk_interface      = "virtio"
    boot_wait           = "10s"
    headless            = true
    disk_detect_zeroes  = "unmap"
    skip_compaction     = false
    disk_compression    = true
  }

  # Run scripts to apply Nutanix best practices
  provisioner "shell" {
    execute_command   = "sudo -E bash '{{ .Path }}'"
    scripts           = [
                          "centos/scripts/nutanix/ntnx_disable_transparent_hugepage.sh",
                          "centos/scripts/nutanix/ntnx_grub2_mkconfig.sh",
                          "centos/scripts/nutanix/ntnx_iscsi_settings.sh",
                          "centos/scripts/nutanix/ntnx_kernel_settings.sh",
                          "centos/scripts/nutanix/ntnx_set_disk_timeout.sh",
                          "centos/scripts/nutanix/ntnx_set_max_sectors_kb.sh",
                          "centos/scripts/nutanix/ntnx_set_noop.sh",
                        ]
    expect_disconnect = false
  }

  # Run scripts to apply OS hardening
  provisioner "shell" {
    execute_command   = "sudo -E bash '{{ .Path }}'"
    scripts           = [
                          "centos/scripts/centos/security_hardening_etckeeper.sh",
                          "centos/scripts/centos/security_hardening_repos.sh",
                          "centos/scripts/centos/security_hardening_pam.sh",
                          "centos/scripts/centos/security_hardening_modprobe.sh",
                          "centos/scripts/centos/security_hardening_modprobe.sh",
                          "centos/scripts/centos/security_firewalld_enable.sh",
                          "centos/scripts/centos/security_hardening_umask.sh",
                          "centos/scripts/centos/security_hardening_fstab.sh",
                          "centos/scripts/centos/security_hardening_passwords.sh",
                          "centos/scripts/centos/security_hardening_tcp_wrappers.sh",
                          "centos/scripts/centos/security_hardening_secure_tty.sh",
                          "centos/scripts/centos/security_hardening_auditd.sh",
                          "centos/scripts/centos/security_hardening_oscap.sh",
                          "centos/scripts/centos/security_hardening_grub.sh",
                          "centos/scripts/centos/security_hardening_crond.sh",
                          "centos/scripts/centos/security_hardening_aide.sh",
                        ]
    expect_disconnect = false
  }

  # Run scripts to prepare to seal the OS image
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/linux-common/cleanup-network.sh",
                          "scripts/linux-sysprep/sysprep-op-dhcp-client-state.sh",
                         ]
    expect_disconnect  = true
  }
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/linux-common/cleanup-disk-space.sh",
                          "scripts/linux-common/cleanup-rpm-db.sh",
                          "scripts/linux-common/get_cloud-init_config.sh",
                          "scripts/linux-common/cleanup-network.sh",
                          "scripts/centos/security_hardening_sshd.sh",
                          "scripts/linux-sysprep/sysprep-op-cloud-init.sh",
                          "scripts/linux-sysprep/sysprep-op-crash-data.sh",
                          "scripts/linux-sysprep/sysprep-op-firewall-rules.sh",
                          "scripts/centos/security_selinux_set_enforcing.sh",
                          "scripts/linux-sysprep/sysprep-op-machine-id.sh",
                          "scripts/linux-sysprep/sysprep-op-package-manager-cache.sh",
                          "scripts/linux-sysprep/sysprep-op-package-manager-db.sh",
                          "scripts/linux-sysprep/sysprep-op-ssh-hostkeys.sh",
                          "scripts/linux-sysprep/sysprep-op-yum-uuid.sh",
                          "scripts/linux-sysprep/sysprep-op-tmp-files.sh",
                          "scripts/linux-sysprep/sysprep-op-logfiles.sh",
                          "scripts/linux-sysprep/sysprep-op-bash-history.sh",
                          "scripts/linux-common/reset-root-password.sh",
                         ]
    expect_disconnect  = false
  }
}
