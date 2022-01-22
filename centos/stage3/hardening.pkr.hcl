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
  iso_url             = "stage2/kvm/ntnx-${var.os}-${var.os_ver}-ahv-x86_64.qcow2"
  iso_checksum        = "file:stage2/kvm/ntnx-${var.os}-${var.os_ver}-basic.md5.checksum"
  output_directory    = "stage${var.build_stage}/kvm"
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
  iso_url             = "stage2/kvm/ntnx-${var.os}-${var.os_ver}-ahv-lvm-x86_64.qcow2"
  iso_checksum        = "file:stage2/kvm/${var.os}-${var.os_ver}-lvm.md5.checksum"
  output_directory    = "stage${var.build_stage}/kvm"
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
      output              = "stage${var.build_stage}/kvm/${var.os}-${var.os_ver}-${source.name}.{{.ChecksumType}}.checksum"
    }

    post-processor "manifest" {
      output = "stage${var.build_stage}/kvm/manifest.json"
    }

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
                         ]
    expect_disconnect  = false
  }
}
