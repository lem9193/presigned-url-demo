output "subnet_ids" {
  value = [
    for subnet in aws_subnet.subnets : subnet.id
  ]
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}
