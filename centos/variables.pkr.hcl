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
//variable "ks_file" {
//  type        = string
//  description = "The filename for the kickstart file to be used in creating the image"
//}
//variable "vm_name" {
//  type        = string
//  description = "The vm name of the image"
//}
variable "os" {
  type        = string
  description = "The name of the distribution for the image"
}
variable "os_ver" {
  type        = string
  description = "The OS version for the image"
}
