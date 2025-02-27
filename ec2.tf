resource "aws_instance" "webapp_ec2" {
  ami                         = var.packer_ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = "my_key_pair"

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  disable_api_termination = false

  tags = {
    Name = var.instance_name
  }

  depends_on = [aws_internet_gateway.igw, aws_security_group.app_sg]
}





