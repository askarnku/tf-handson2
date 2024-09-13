resource "aws_route_table" "rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = var.cidr_block
    gateway_id     = var.igw_id == null ? null : var.igw_id
    nat_gateway_id = var.nat_gw_id == null ? null : var.nat_gw_id
  }

  tags = {
    Name = "${var.igw_id != null ? "public" : "private"}_rt"
  }
}

