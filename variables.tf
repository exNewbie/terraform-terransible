###########################################################
# Variables
variable "aws_region" {}

variable "aws_profile" {}
variable "vpc_cidr" {}
variable "localip" {}
variable "domain_name" {}
variable "actual_domain_name" {}
variable "sub_domain" {}

variable "db_instance_class" {}
variable "dbname" {}
variable "dbusername" {}
variable "dbpassword" {}

variable "dev_instance_type" {}
variable "dev_ami" {}
variable "public_key_path" {}
variable "key_name" {}

variable "elb_healthy_threshold" {}
variable "elb_unhealthy_threshold" {}
variable "elb_timeout" {}
variable "elb_interval" {}

variable "asg_max" {}
variable "asg_min" {}
variable "asg_grace" {}
variable "asg_hct" {}
variable "asg_cap" {}
variable "lc_instance_type" {}

variable "delegation_set" {}

variable "cidrs" {
  type = "map"
}

###########################################################
# Data
data "aws_availability_zones" "available" {}
