resource "aws_instance" "main" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  tags = {
    Name = var.name
  }
}

output "instance_id" {
  value = aws_instance.main.id
}
output "public_ip" {
  value = aws_instance.main.public_ip
}
