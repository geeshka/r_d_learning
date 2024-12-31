
# README

## Опис проекту

Цей проект демонструє використання Terraform для створення та управління інфраструктурою AWS. Ми виконали два основні завдання:
1. Створення VPC, підмереж, EC2 інстансів та інших ресурсів за допомогою модулів Terraform.
2. Імпорт вручну створених ресурсів через AWS Management Console у Terraform конфігурацію для подальшого управління ними.

---

## Кроки виконання

### 1. Створення конфігурацій Terraform

Було створено модулі для наступних ресурсів:
- **VPC**: базова віртуальна приватна мережа з підтримкою DNS.
- **Підмережі**: публічна та приватна підмережі.
- **EC2 інстанси**: один у публічній підмережі, інший у приватній.

![Alt-текст](<1.png>)
![Alt-текст](<2.png>)

Основний файл `main.tf` включає визначення модулів:
```hcl
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
```
![Alt-текст](<3.png>)
![Alt-текст](<4.png>)
Доповнюємо налаштування output в main.tf
![Alt-текст](<5.png>)
### 2. Імпорт вручну створених ресурсів

Через AWS Management Console були створені наступні ресурси:
- **VPC**
- **Публічна підмережа**
- **Приватна підмережа**
- **Internet Gateway**
- **Таблиці маршрутизації**
- **S3 Endpoint**
![Alt-текст](<6.png>)
![Alt-текст](<7.png>)
![Alt-текст](<8.png>)
До `main.tf` були додані ресурси для імпорту:
```hcl
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
```

Команди для імпорту:
```bash
terraform import aws_vpc.imported vpc-0e8d8e07bdef4dab5
terraform import aws_subnet.public_subnet_imported subnet-0176d065dfdac8df8
terraform import aws_subnet.private_subnet_imported subnet-02d004a8dedbc2c108
terraform import aws_internet_gateway.imported igw-0143e87073abc3c74
terraform import aws_route_table.public_route_table_imported rtb-0d077a4153bb5e893
terraform import aws_route_table.private_route_table_imported rtb-035c6e41e0db70a73
terraform import aws_vpc_endpoint.s3_endpoint_imported vpce-0188f9688c7ab4a44
```
![Alt-текст](<9.png>)
![Alt-текст](<10.png>)
![Alt-текст](<11.png>)
### 3. Видалення ресурсів

Для видалення всіх ресурсів використано:
```bash
terraform destroy
```
![Alt-текст](<12.png>)
---

## Результати

Було успішно:
1. Створено інфраструктуру за допомогою Terraform.
2. Імпортовано вручну створені ресурси для подальшого управління.
3. Видалено всі ресурси після завершення роботи.
