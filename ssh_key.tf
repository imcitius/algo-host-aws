
resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
}

resource "random_uuid" "ssh_key_id" { }

resource "aws_key_pair" "ssh" {
  key_name   = "${random_uuid.ssh_key_id.result}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}
