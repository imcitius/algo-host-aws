data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "algo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"
  key_name      = aws_key_pair.ssh.key_name
  associate_public_ip_address = true
  private_ip    = "10.0.0.12"

  subnet_id     = aws_subnet.algo.id

  vpc_security_group_ids = [
    aws_security_group.algo.id
  ]

  tags = {
    Name = "algo instance"
  }

  provisioner "local-exec" {
      command = "echo '${tls_private_key.ssh.private_key_pem}' > private_key.txt && chmod 600 private_key.txt"
  }

  provisioner "local-exec" {
      command = "echo '${aws_instance.algo.public_ip}' > private_ip.txt && chmod 600 private_ip.txt"
  }

  provisioner "local-exec" {
    command = "./provision.sh"
    interpreter = ["/bin/bash"]
  }
}
