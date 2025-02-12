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
