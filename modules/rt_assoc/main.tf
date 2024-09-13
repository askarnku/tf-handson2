resource "aws_route_table_association" "a" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = var.route_table_id
}
