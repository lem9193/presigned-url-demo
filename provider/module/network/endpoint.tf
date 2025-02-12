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


