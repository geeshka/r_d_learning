resource "aws_subnet" "main" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  map_public_ip_on_launch = var.public
  availability_zone       = var.availability_zone
  tags = {
    Name = var.name
  }
}

output "subnet_id" {
  value = aws_subnet.main.id
}
