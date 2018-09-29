variable "dc1-sg" {}
variable "dc2-sg" {}

variable "dc1-public-ips" {
  type = "list"
}

variable "dc2-public-ips" {
  type = "list"
}

variable "enabled" {
  default = 0
}
