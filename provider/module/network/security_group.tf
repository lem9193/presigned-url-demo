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


