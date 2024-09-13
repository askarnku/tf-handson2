resource "aws_instance" "ec2" {
  count = length(var.public_subnet_ids)

  ami = data.aws_ami.this.id

  instance_type   = var.instance_type
  security_groups = var.public_ec2_sg
  subnet_id       = var.public_subnet_ids[count.index]
  key_name        = data.aws_key_pair.key.key_name
  user_data       = var.user_data


  tags = {
    Name = "server_${count.index}"
  }
}
