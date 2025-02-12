variable "prefix" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "ingress_cidr_block" {
  type = string
}

variable "subnet_count" {
  type = number
}

variable "add_route" {
  type = bool
}
