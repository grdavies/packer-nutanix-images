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
variable "cpus" {
  default     = 2
}
variable "memory" {
  default     = 1024
}
variable "build_stage" {
  type        = number
  default     = 1
}
variable "shutdown_command" {
  type        = string
  default     = "shutdown_command": "shutdown /s /t 10 /f /d p:4:1",
}
