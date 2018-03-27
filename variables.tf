###########################################################
# Variables
variable "aws_region" {}

variable "aws_profile" {}
variable "vpc_cidr" {}
variable "localip" {}
variable "domain_name" {}

variable "db_instance_class" {}
variable "dbname" {}
variable "dbusername" {}
variable "dbpassword" {}

variable "dev_instance_type" {}
variable "dev_ami" {}
variable "public_key_path" {}
variable "key_name" {}

variable "cidrs" {
  type = "map"
}

###########################################################
# Data
data "aws_availability_zones" "available" {}
