variable "prefix" {
  type = string
}

variable "resolver_security_group_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}
