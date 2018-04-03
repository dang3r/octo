variable "size" {
  type    = "string"
  default = "8"
}

variable "ssh_key_path" {
  type    = "string"
  default = "~/.ssh/id_rsa.pub"
}

variable "octo_secret" {
  type    = "string"
}

variable "target_url" {
  type    = "string"
}
