terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }
}

resource "random_string" "suffix" {
  length = 4
  special = false
  upper = false
}

provider "aws" {
  region = var.region
}

resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "terramino_ingress" {
  name   = "terramino-ui-ingress-${random_string.suffix.result}"
  vpc_id = aws_default_vpc.default.id

  # Backend
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Frontend
  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "terramino" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.terramino_ingress.id
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "16"
    delete_on_termination = "true"
  }

  tags = {
    Name = "Terramino-${random_string.suffix.result}"
  }
}

output "backend-ui" {
  value = "http://${aws_instance.terramino.public_ip}:8080"
}

output "frontend-ui" {
  value = "http://${aws_instance.terramino.public_ip}:8081"
}