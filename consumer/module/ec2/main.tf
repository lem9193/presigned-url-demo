data "aws_ami" "aml_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-arm64"]
  }
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.aml_2023.id
  instance_type          = "t4g.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  user_data              = <<EOF
#!/bin/bash
cat << 'EOF' > /home/ec2-user/index.html
Hello World !
EOF
  tags = {
    Name = "${var.prefix}-ec2"
  }
}


