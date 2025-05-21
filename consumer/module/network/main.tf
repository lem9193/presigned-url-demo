resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "subnets" {
  count = var.subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "${var.prefix}-subnet${format("%02d", count.index + 1)}"
  }
}

resource "aws_network_acl" "main" {

  vpc_id     = aws_vpc.main.id
  subnet_ids = [for subnet in aws_subnet.subnets : subnet.id]

  tags = {
    Name = "${var.prefix}-nacl"
  }
}

resource "aws_network_acl_rule" "inbound" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  egress         = false
}

resource "aws_network_acl_rule" "outbound" {
  network_acl_id = aws_network_acl.main.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  egress         = true
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-rt"
  }
}

resource "aws_route_table_association" "main" {
  count = var.subnet_count

  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.main.id
}

resource "aws_route" "main" {
  route_table_id            = aws_route_table.main.id
  destination_cidr_block    = var.destination_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# EC2 Instance Connect Security Group
resource "aws_security_group" "eic" {
  name   = "${var.prefix}-eic-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "eic_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eic.id
}

# EC2 Security Group 
resource "aws_security_group" "ec2" {
  name   = "${var.prefix}-ec2-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eic.id
  security_group_id        = aws_security_group.ec2.id
}

resource "aws_ec2_instance_connect_endpoint" "eic" {
  subnet_id          = aws_subnet.subnets[0].id
  security_group_ids = [aws_security_group.eic.id]
  preserve_client_ip = true
  tags = {
    Name = "${var.prefix}-eic"
  }
}

resource "aws_vpc_peering_connection" "main" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-peering"
  }
}

