provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  name       = "my-vpc"
}

module "public_subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  public            = true
  name              = "public-subnet"
}

module "private_subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1a"
  public            = false
  name              = "private-subnet"
}

module "public_instance" {
  source       = "./modules/ec2"
  ami          = "ami-02df5cb5ad97983ba"
  instance_type = "t3.micro"
  subnet_id    = module.public_subnet.subnet_id
  name         = "public-instance"
}

module "private_instance" {
  source       = "./modules/ec2"
  ami          = "ami-02df5cb5ad97983ba"
  instance_type = "t3.micro"
  subnet_id    = module.private_subnet.subnet_id
  name         = "private-instance"
}

resource "aws_vpc" "imported" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "imported-vpc"
  }
}

resource "aws_subnet" "public_subnet_imported" {
  vpc_id     = aws_vpc.imported.id
  cidr_block = "10.1.0.0/20"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "imported-subnet-public1-eu-north-1a"
  }
}

resource "aws_subnet" "private_subnet_imported" {
  vpc_id     = aws_vpc.imported.id
  cidr_block = "10.1.128.0/20"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "imported-subnet-private1-eu-north-1a"
  }
}

resource "aws_internet_gateway" "imported" {
  vpc_id = aws_vpc.imported.id
  tags = {
    Name = "imported-igw"
  }
}

resource "aws_route_table" "public_route_table_imported" {
  vpc_id = aws_vpc.imported.id
  tags = {
    Name = "imported-rtb-public"
  }
}

resource "aws_route_table" "private_route_table_imported" {
  vpc_id = aws_vpc.imported.id
  tags = {
    Name = "imported-rtb-private1-eu-north-1a"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint_imported" {
  vpc_id            = aws_vpc.imported.id
  service_name      = "com.amazonaws.eu-north-1.s3"
  vpc_endpoint_type = "Gateway"
  tags = {
    Name = "imported-vpce-s3"
  }
}


output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID созданного VPC"
}

output "imported_vpc_id" {
  value       = aws_vpc.imported.id
  description = "ID импортированной VPC"
}

output "public_subnet_id" {
  value       = module.public_subnet.subnet_id
  description = "ID публичной подсети"
}

output "private_subnet_id" {
  value       = module.private_subnet.subnet_id
  description = "ID приватной подсети"
}

output "imported_public_subnet_id" {
  value       = aws_subnet.public_subnet_imported.id
  description = "ID импортированной публичной подсети"
}

output "imported_private_subnet_id" {
  value       = aws_subnet.private_subnet_imported.id
  description = "ID импортированной приватной подсети"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.imported.id
  description = "ID импортированного интернет-шлюза"
}

output "public_route_table_id" {
  value       = aws_route_table.public_route_table_imported.id
  description = "ID импортированной таблицы маршрутов для публичной подсети"
}

output "private_route_table_id" {
  value       = aws_route_table.private_route_table_imported.id
  description = "ID импортированной таблицы маршрутов для приватной подсети"
}

output "s3_endpoint_id" {
  value       = aws_vpc_endpoint.s3_endpoint_imported.id
  description = "ID импортированного S3 Endpoint"
}

output "public_instance_id" {
  value       = module.public_instance.instance_id
  description = "ID EC2-инстанса в публичной подсети"
}

output "private_instance_id" {
  value       = module.private_instance.instance_id
  description = "ID EC2-инстанса в приватной подсети"
}

output "public_instance_public_ip" {
  value       = module.public_instance.public_ip
  description = "Публичный IP адрес EC2-инстанса в публичной подсети"
}
