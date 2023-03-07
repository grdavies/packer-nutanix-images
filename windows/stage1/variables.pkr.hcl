// centos/variables.pkr.hcl
variable "disk_size" {
  type        = string
  default     = "200G"
  description = "Template disk size"
}
variable "iso_url" {
  type        = string
  description = "URL for the distribution minimal install ISO"
}
variable "iso_checksum" {
  type        = string
  description = "URL for the distribution minimal install ISO checksum"
}
variable "iso_checksum_type" {
  type        = string
  description = "The type of checksum supplied (md5, sha256 etc)"
}
variable "os" {
  type        = string
  description = "The name of the distribution for the image"
}
variable "os_ver" {
  type        = string
  description = "The OS version for the image"
}
variable "os_edition" {
  type        = string
  description = "The OS edition for the image"
}
variable "cpus" {
  default     = 2
}
variable "memory" {
  default     = 8192
}
variable "build_stage" {
  type        = number
  default     = 1
}
variable "shutdown_command" {
  type        = string
  default     = "shutdown /s /t 10 /f /d p:4:1"
}
variable "communicator_timeout" {
  type        = string
  description = "WinRM timeout"
  default     = "5985"
}
variable "communicator_username" {
  type        = string
  description = "WinRM username"
}
variable "communicator_password" {
  type        = string
  description = "WinRM password"
}
variable "communicator_port" {
  type        = string
  description = "WinRM port"
}
variable "communicator_pause" {
  type        = string
  description = ""
}
variable "os_language" {
  type        = string
  description = "Windows language setting"
}
variable "os_keyboard" {
  type        = string
  description = "Windows keyboard setting"
}
variable "os_install_type" {
  type        = string
  description = "Whether install is full or core"
}
variable "boot_command" {
  type        = list(string)
  description = ""
}
variable "kms_key" {
  type        = string
  description = ""
}
variable "boot_order" {
  type        = string
  description = ""
}
variable "boot_wait" {
  type        = string
  description = ""
}
variable "scripts" {
  type        = list(string)
  description = ""
}
variable "inline_scripts" {
  type        = list(string)
  description = ""
}
variable "floppy_files" {
  type        = list(string)
  description = ""
}
