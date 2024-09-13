resource "aws_subnet" "this" {
  count                   = length(var.subnets)
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnets[count.index].cidr_block
  availability_zone       = var.subnets[count.index].az
  map_public_ip_on_launch = var.subnets[count.index].map_public_ip

  tags = {
    Name = var.subnets[count.index].tag_name
  }
}
