locals {
  vpc_id       = "192.168.1.0/24"
  subnet_cidrs = ["192.168.1.0/26", "192.168.1.64/26", "192.168.1.128/26", "192.168.1.192/26"]
  azs          = ["us-east-1a", "us-east-1b"]
}


module "vpc" {
  source = "./modules/vpc"

  cidr_block = local.vpc_id
  vpc_tag    = "main_vpc"
}

module "subnets" {
  source = "./modules/subnet"

  vpc_id = module.vpc.id
  subnets = [
    {
      cidr_block    = local.subnet_cidrs[0]
      az            = local.azs[0]
      map_public_ip = true
      tag_name      = "public-subnet-1a"
    },
    {
      cidr_block    = local.subnet_cidrs[1]
      az            = local.azs[0]
      map_public_ip = false
      tag_name      = "private-subnet-1a"
    },
    {
      cidr_block    = local.subnet_cidrs[2]
      az            = local.azs[1]
      map_public_ip = true
      tag_name      = "public-subnet-1b"
    },
    {
      cidr_block    = local.subnet_cidrs[3]
      az            = local.azs[1]
      map_public_ip = false
      tag_name      = "private-subnet-1b"
    },
  ]
}

module "igw" {
  source  = "./modules/igw"
  vpc_id  = module.vpc.id
  igw_tag = "igw"
}

module "nat_gw" {
  source = "./modules/nat_gw"

  public_subnet_id = slice([for subnet in module.subnets.subnets : subnet.id if subnet.map_public_ip_on_launch == true], 0, 1)[0]
  nat_tag          = "nat_gw"
}

# create public rt
module "public_rt" {
  source = "./modules/rt"

  vpc_id     = module.vpc.id
  nat_gw_id  = null
  igw_id     = module.igw.id
  cidr_block = "0.0.0.0/0"
}

# create private rt
module "private_rt" {
  source = "./modules/rt"

  vpc_id     = module.vpc.id
  nat_gw_id  = module.nat_gw.id
  igw_id     = null
  cidr_block = "0.0.0.0/0"
}

module "public_rt_assoc" {
  source         = "./modules/rt_assoc"
  subnet_ids     = module.subnets.public_subnet_ids
  route_table_id = module.public_rt.id
}

module "private_rt_assoc" {
  source         = "./modules/rt_assoc"
  subnet_ids     = module.subnets.private_subnet_ids
  route_table_id = module.private_rt.id
}

#sg for alb
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow http"
  vpc_id      = module.vpc.id

  ingress {
    description = "http from the world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https from the world"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "public_ec2_sg" {
  name        = "alb_sg"
  description = "allow http and https traffic everywhere"
  vpc_id      = module.vpc.id

  ingress {
    description = "ssh from the world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "http from the ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_ec2_public"
  }
}

module "ec2" {
  source = "./modules/ec2"

  public_subnet_ids = module.subnets.public_subnet_ids
  public_ec2_sg     = [aws_security_group.public_ec2_sg.id]
  user_data         = <<EOT
    #!/bin/bash
    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
EOT
}

