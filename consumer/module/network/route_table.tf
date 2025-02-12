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

