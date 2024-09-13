# spits out list of subnet ids
output "ids" {
  value = aws_subnet.this[*].id
}

output "subnets" {
  value = aws_subnet.this[*]
}

# list of public subnets
output "public_subnet_ids" {
  value = [for subnet in aws_subnet.this[*] : subnet.id if subnet.map_public_ip_on_launch == true]
}

# list of private subnets
output "private_subnet_ids" {
  value = [for subnet in aws_subnet.this[*] : subnet.id if subnet.map_public_ip_on_launch == false]
}
