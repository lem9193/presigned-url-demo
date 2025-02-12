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

