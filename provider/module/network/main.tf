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

data "aws_vpc_peering_connections" "main" {
  filter {
    name   = "accepter-vpc-info.vpc-id"
    values = [aws_vpc.main.id]
  }

  filter {
    name   = "status-code"
    values = ["active"]
  }
}

resource "aws_route" "peering" {
  count                     = var.add_route ? 1 : 0
  route_table_id            = aws_route_table.main.id
  destination_cidr_block    = var.ingress_cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connections.main.ids[0]

  lifecycle {
    create_before_destroy = true
  }
}

# ENI Security Group
resource "aws_security_group" "eni" {
  name   = "${var.prefix}-eni-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "eni_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eni.id
}

resource "aws_security_group_rule" "eni_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.ingress_cidr_block]
  security_group_id = aws_security_group.eni.id
}

# Resolver Security Group
resource "aws_security_group" "resolver" {
  name   = "${var.prefix}-resolver-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "resolver_ingress_udp" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = [var.ingress_cidr_block]
  security_group_id = aws_security_group.resolver.id
}

resource "aws_vpc_endpoint" "gw_s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.main.id]
  tags = {
    Name = "${var.prefix}-gw-s3"
  }
}

resource "aws_vpc_endpoint" "if_s3" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.subnets : subnet.id]
  security_group_ids  = [aws_security_group.eni.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.prefix}-if-s3"
  }
  depends_on = [aws_vpc_endpoint.gw_s3]
}