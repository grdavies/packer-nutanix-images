// centos/variables.pkr.hcl
variable "disk_size" {
  type        = string
  default     = "100G"
  description = "Template disk size"
}
variable "shutdown_command" {
  type        = string
  default     = "sudo -S shutdown -P now"
  description = "Template disk size"
}
variable "iso_url" {
  type        = string
  description = "URL for the distribution minimal install ISO"
}
variable "iso_checksum_url" {
  type        = string
  description = "URL for the distribution minimal install ISO checksum"
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
  default = 2
}
variable "memory" {
  default = 1024
}
variable "build_stage" {
  type = number
  default = 1
}
