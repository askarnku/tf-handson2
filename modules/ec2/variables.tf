variable "public_subnet_ids" {

}

variable "instance_type" {
  default = "t2.micro"
}

variable "public_ec2_sg" {
  type = list(any)
}

variable "user_data" {

}
