terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Define um VPC para o seu projeto
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# Define as sub-redes em diferentes zonas de disponibilidade
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Altere para uma AZ da sua região
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Altere para uma AZ da sua região
}

# Cria o DB Subnet Group para o RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group-academy"
  subnet_ids  = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  description = "DB subnet group for the RDS instance"
}


