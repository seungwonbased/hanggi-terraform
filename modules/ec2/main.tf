resource "aws_instance" "bastion-host" {
  ami           = "ami-093467ec28ae4fe03"
  instance_type = "t2.micro"
  subnet_id = var.subnet_id
  key_name = aws_key_pair.bastion-host-key-pair.key_name
  security_groups = [ var.security_group_id ]
}


resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "bastion-host-key-pair" {
  key_name   = "bastion-host-key-pair"
  public_key = tls_private_key.private-key.public_key_openssh
}


resource "local_file" "private_key" {
  filename = "/Users/baeseungwon/aws/hanggi/.ssh/bastion-host-key-pair.pem"
  content  = tls_private_key.private-key.private_key_pem
}


output "id" {
  value = aws_instance.bastion-host.id
}