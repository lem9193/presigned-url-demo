resource "aws_vpc_peering_connection" "main" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-peering"
  }
}
