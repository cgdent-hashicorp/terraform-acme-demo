variable "project_name" { default = "acme-webapp-demo" }
variable "region" { default = "ap-southeast-2" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnet_cidr" { default = "10.0.1.0/24" }
variable "instance_type" { default = "t2.medium" }
variable "ami" { default = "ami-0ac4101c751eae35f" }
variable "tags" { type = map(string) }
