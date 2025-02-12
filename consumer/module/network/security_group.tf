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
