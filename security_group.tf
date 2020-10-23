resource "aws_security_group" "algo" {
  name        = "algo"
  description = "Allow VPN inbound traffic"
  vpc_id      = aws_vpc.algo.id

  # icmp
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # openvpn
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # ipsec
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # MobIKE
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # WireGuard
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # any outbound
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "algo"
  }

}