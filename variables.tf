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
  description = "AWS instance type "
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "5"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "4"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "env-name" {
    description = "desired env for deployment"
}
