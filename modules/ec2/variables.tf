variable "public_subnet_ids" {

}

variable "instance_type" {
  default = "t2.micro"
}

# variable "public_ec2_sg" {
#   type = list(any)
# }

variable "user_data" {

}

variable "ami_name" {

}

variable "security_group_ids" {
  description = "List of security groups"
  type        = list(string)
}
