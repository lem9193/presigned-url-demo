resource "aws_route53_resolver_endpoint" "main" {
  name               = "${var.prefix}-resolver-inbound"
  direction          = "INBOUND"
  security_group_ids = [var.resolver_security_group_id]
  dynamic "ip_address" {
    for_each = var.subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }
}
