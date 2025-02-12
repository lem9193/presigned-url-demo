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
