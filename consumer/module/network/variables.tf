variable "prefix" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "destination_cidr_block" {
  type = string
}

variable "subnet_count" {
  type = number
}

variable "peer_owner_id" {
  type = string
}

variable "peer_vpc_id" {
  type = string
}
