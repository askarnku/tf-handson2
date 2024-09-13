variable "vpc_id" {

}

variable "subnets" {
  type = list(object({
    cidr_block    = string
    az            = string
    map_public_ip = bool
    tag_name      = string
  }))
}

