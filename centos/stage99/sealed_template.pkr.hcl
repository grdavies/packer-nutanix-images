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
  iso_url             = "stage2/kvm/basic-ntnx/${var.os}-${var.os_ver}-basic-ntnx.qcow2"
  iso_checksum        = "file:stage2/kvm/basic-ntnx/${var.os}-${var.os_ver}-basic-ntnx.md5.checksum"
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

source "qemu" "basic-ntnx-hardened-template" {
  disk_image          = true
  iso_url             = "stage3/kvm/basic-ntnx-hardened/${var.os}-${var.os_ver}-basic-ntnx-hardened.qcow2"
  iso_checksum        = "file:stage3/kvm/basic-ntnx-hardened/${var.os}-${var.os_ver}-basic-ntnx-hardened.md5.checksum"
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
  iso_url             = "stage3/kvm/lvm-ntnx-hardened/${var.os}-${var.os_ver}-lvm-ntnx-hardened.qcow2"
  iso_checksum        = "file:stage3/kvm/lvm-ntnx-hardened/${var.os}-${var.os_ver}-lvm-ntnx-hardened.md5.checksum"
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

    #post-processor "manifest" {
    #  output = "stage${var.build_stage}/kvm/manifest.json"
    #}

  }

  ## Run scripts to prepare to seal the OS image
  # Cleanup network interface configurations
  provisioner "shell" {
    script = "scripts/linux-common/cleanup-network.sh"
    expect_disconnect   = true
  }

  # Remove DHCP client lease information
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-dhcp-client-state.sh"
    expect_disconnect   = true
  }

  # Zero out the free space
  provisioner "shell" {
    script              = "scripts/linux-common/cleanup-disk-space.sh"
    expect_disconnect   = false
    timeout             = "30m"
  }

  # Remove any host specific RPM database files
  provisioner "shell" {
    script              = "scripts/linux-common/cleanup-rpm-db.sh"
    expect_disconnect   = false
  }

  # Remove network configuration
  provisioner "shell" {
    script              = "scripts/linux-common/cleanup-network.sh"
    expect_disconnect   = false
  }

  # Apply sshd best practices for security
  provisioner "shell" {
    script              = "scripts/centos/security_hardening_sshd.sh"
    expect_disconnect   = true
  }

  # Remove all cloud-init run-time data and logs
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-cloud-init.sh"
    expect_disconnect   = false
  }

  # Print cloud-config configuration to log
  provisioner "shell" {
    script              = "scripts/linux-common/get_cloud-init_config.sh"
    expect_disconnect   = false
  }

  # Remove crash data
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-crash-data.sh"
    expect_disconnect   = false
  }

  # Remove any custom firewall rules or firewalld configuration
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-firewall-rules.sh"
    expect_disconnect   = false
  }

  # Set selinux to enforcing mode
  provisioner "shell" {
    script              = "scripts/centos/security_selinux_set_enforcing.sh"
    expect_disconnect   = false
  }

  # Remove the local machine id
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-machine-id.sh"
    expect_disconnect   = false
  }

  # Remove cache files associated with the guests package manager
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-package-manager-cache.sh"
    expect_disconnect   = false
  }

  # Remove dynamically created package manager files
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-package-manager-db.sh"
    expect_disconnect   = false
  }

  # Remove the guests ssh host keys
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-ssh-hostkeys.sh"
    expect_disconnect   = false
  }

  # Remove the yum package manager UUID
  provisioner "shell" {
    script              = "scripts/linux-sysprep/sysprep-op-yum-uuid.sh"
    expect_disconnect   = false
  }

  # Remove temporary files
  provisioner "shell" {
    script = "scripts/linux-sysprep/sysprep-op-tmp-files.sh"
    expect_disconnect  = false
  }

  # Remove log files
  provisioner "shell" {
    script = "scripts/linux-sysprep/sysprep-op-logfiles.sh"
    expect_disconnect  = false
    except = [ "qemu.basic-ntnx-hardened-template", "qemu.lvm-ntnx-hardened-template" ]
  }

  # Remove bash command history files
  provisioner "shell" {
    script = "scripts/linux-sysprep/sysprep-op-bash-history.sh"
    expect_disconnect  = false
  }

  # Reset the root password to a randomly generated string
  provisioner "shell" {
    script = "scripts/linux-common/reset-root-password.sh"
    expect_disconnect  = false
  }
}
