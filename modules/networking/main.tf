data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

//here we retrieve two AZs from our data sources that are available for db instances
locals {
  selected_azs = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )
}

//This is our vpc, the hearth of our network infrastructure
resource "aws_vpc" "our_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

//Here is our igw that allows traffic from/to the internet with our running web-instances (e.g wordpress on ec2) in our public subnet
resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = aws_vpc.our_vpc.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}


//Here we have our public subnet, route table (rt) and rt-association
// 1. public subnet 
resource "aws_subnet" "public_sn" {
  vpc_id            = aws_vpc.our_vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = local.selected_azs[0]
  //This configuration makes our instances publicly available/reachable
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-web"
    Tier = "public"
  })
}

//2. rt to our public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.our_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

//3. associate our rt to our public subnet
resource "aws_route_table_association" "public_arta" {
  subnet_id      = aws_subnet.public_sn.id
  route_table_id = aws_route_table.public_rt.id
}

//Security group that allwos access to Wordpress publicly
resource "aws_security_group" "web" {
  vpc_id      = aws_vpc.our_vpc.id
  name_prefix = "${var.name_prefix}-web-"
  description = "Security group allow access to Wordpress publicly"
  //Revokes alls SGs rules attached to ingress or egress before deleting the rule itself
  //Helpful when dismantling the infrastructure
  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP from the internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  //In case we want to test our infrastructure, we dont need https
  count = var.enable_https ? 1 : 0

  security_group_id = aws_security_group.web.id
  description       = "HTTPS from the internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "Required package, WordPress, and database egress for outbound communication"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

//Here we have our private subnet in which the database (RDS) will reside
// No custom route table is required for this exercise.
// These subnets implicitly use the VPC main route table,
// which contains the local VPC route but no internet route.
// 1. Define two private subnets for RDS
resource "aws_subnet" "private_db_sn" {
  // Two private subnets are required so the RDS subnet group spans two AZs
  //RDS module creates one logical Multi-AZ database:aws_db_instance primary DB and a synchronized standby DB
  count = 2

  vpc_id = aws_vpc.our_vpc.id
  // Each private subnet requires its own non-overlapping CIDR block
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = local.selected_azs[count.index]
  //Disallow to connect via a public ip to our RDS instance_class, since reserved in private subnet for wordpress ec2 instance
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-db-${count.index + 1}"
    Tier = "private"
  })
}

//2. We define our SG rule for the RDS instances
resource "aws_security_group" "rds" {
  name_prefix            = "${var.name_prefix}-rds-"
  description            = "MySQL access only from the WordPress web server"
  vpc_id                 = aws_vpc.our_vpc.id
  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-sg"
  })
}

//3.This one allows acces communication between Wordpress to our RDS(MySQL)
//It permits: EC2 web security group → TCP 3306 → RDS security group
resource "aws_vpc_security_group_ingress_rule" "mysql_from_web" {
  security_group_id            = aws_security_group.rds.id
  description                  = "MySQL from the WordPress security group"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}