// centos/ntnx-centos-7.9-hardened.pkrvars.hcl
iso_url           = "http://centos-distro.cavecreek.net/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"
iso_checksum_url  = "http://centos-distro.cavecreek.net/7.9.2009/isos/x86_64/sha256sum.txt"
ks_file           = "centos-7.9-ahv-x86_64-hardened.cfg"
vm_name           = "centos-7.9-ahv-x86_64-hardened"
os                = "centos"
os_ver            = "7.9"
nutanix_script_files  = [ "scripts/nutanix/ntnx_kernel_settings.sh",
  "scripts/nutanix/ntnx_set_max_sectors_kb.sh",
  "scripts/nutanix/ntnx_set_disk_timeout.sh",
  "scripts/nutanix/ntnx_iscsi_settings.sh",
  "scripts/nutanix/ntnx_set_noop.sh",
  "scripts/nutanix/ntnx_disable_transparent_hugepage.sh"
]
