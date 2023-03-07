// windows/windows-2019-std.pkrvars.hcl
iso_url           = "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
iso_checksum      = "3022424f777b66a698047ba1c37812026b9714c5"
iso_checksum_type = "md5"

// Installation Operating System Metadata
os                = "windows"
os_ver            = "2019"
os_edition        = "std"
os_install_type   = "full"
kms_key           = "N69G4-B89J2-4G8F4-WWYCC-J464C"
os_language       = "en-US"
os_keyboard       = "en-US"
floppy_files      = []

// Boot Settings
boot_order       = "disk,cdrom"
boot_wait        = "2s"
boot_command     = ["<spacebar>"]
shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Shutdown by Packer\""

// Communicator Settings
communicator_username     = "Administrator"
communicator_password     = "Nutanix/4u"
communicator_port         = 5985
communicator_timeout      = "12h"
communicator_pause        = "30m"

// Provisioner Settings
scripts = ["scripts/windows/windows-prepare.ps1"]
inline_scripts = [
  "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
  "choco feature enable -n allowGlobalConfirmation",
  "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }"
]