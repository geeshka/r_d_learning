variable "vpc_id" {
  type        = string
  description = "VPC ID for the subnet"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the subnet"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone for the subnet"
}

variable "public" {
  type        = bool
  description = "Is this a public subnet?"
}

variable "name" {
  type        = string
  description = "Name tag for the subnet"
}
