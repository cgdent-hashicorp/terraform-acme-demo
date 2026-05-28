terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { 
      source = "hashicorp/aws" 
      version = "~> 5.0" 
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "git::https://github.com/cgdent-hashicorp/terraform-aws-vpc-module.git?ref=v1.0.0"

  name               = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  tags               = var.tags
}

resource "aws_security_group" "allow_ssh_icmp" {
  name        = "allow_ssh_icmp"
  description = "Allow SSH and ICMP from specified CIDRs"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # or restrict to your IPs
  }

  ingress {
    description = "Allow ICMP (ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags       = var.tags
}

resource "aws_instance" "web-server-01" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  tags = merge(var.tags, {
    Name = "web-server-01"
  })
}

resource "aws_instance" "web-server-02" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  tags = merge(var.tags, {
    Name = "web-server-02"
  })
}

resource "aws_instance" "web-server-03" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  tags = merge(var.tags, {
    Name = "web-server-03"
  })
}

resource "aws_instance" "backend-01" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  tags = merge(var.tags, {
    Name = "backend-01"
  })
}

resource "aws_instance" "backend-02" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  tags = merge(var.tags, {
    Name = "backend-02"
  })
}

resource "aws_instance" "backend-03" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_id
  tags = merge(var.tags, {
    Name = "backend-03"
  })
}
