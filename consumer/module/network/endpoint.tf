resource "aws_ec2_instance_connect_endpoint" "eic" {
  subnet_id          = aws_subnet.subnets[0].id
  security_group_ids = [aws_security_group.eic.id]
  preserve_client_ip = true
  tags = {
    Name = "${var.prefix}-eic"
  }
}
