#Grab latest ami image for AWS linux 2
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

#create instance to be test jump box
resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Front.id
  private_ip = "10.0.1.10"
  vpc_security_group_ids = [aws_security_group.front_security_group.id]
  key_name = "demokey"
  user_data = file("install_apache.sh")

  tags = {
    Name = "Jump Box"
  }
}

#create middle instance to test ssh
resource "aws_instance" "app" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Middle.id
  private_ip = "10.0.2.10"
  vpc_security_group_ids = [aws_security_group.middle_security_group.id]
  key_name = "demokey"


  tags = {
    Name = "Middle Instance"
  }
}