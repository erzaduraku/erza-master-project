variable "group_name" {
  default = "erza"
}

variable "environment" {
  default = "DEV"
}

variable "project_name" {
  default = "DCADD_MASTER"
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "instance_type" {
  default = "t3.micro"
}

variable "asg_desired_capacity" {
  default = 3
}

variable "asg_min_size" {
  default = 2
}

variable "asg_max_size" {
  default = 6
}