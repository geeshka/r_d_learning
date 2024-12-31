variable "ami" {
  type        = string
  description = "AMI ID for the instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "name" {
  type        = string
  description = "Name tag for the instance"
}
