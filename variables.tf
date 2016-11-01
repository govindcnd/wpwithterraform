variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

# ubuntu-trusty-14.04 (x64)
variable "aws_amis" {
  default = {
    "us-east-1" = "ami-5f709f34"
    "us-west-2" = "ami-7f675e4f"
  }
}

variable "availability_zones" {
  default     = "us-east-1b,us-east-1c"
  description = "List of availability zones "
}

variable "key_name" {
  description = "punch in the pem key"
}

variable "aws_access_key" {
  description = "punch in the access key"
}

variable "aws_secret_key" {
  description = "punch in the secret key"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "1"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "1"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public1_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.4.0/24"
}

variable "public2_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.5.0/24"
}

variable "public3_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.6.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}

