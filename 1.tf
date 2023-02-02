provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "Dev" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Dev-vpc"
  }
}

resource "aws_subnet" "Dev" {
  vpc_id = aws_vpc.Dev.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "Dev-subnet"
  }
}
resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.Dev.id

  tags = {
    Name = "primary_network_interface"
  }

resource "aws_security_group" "Dev" {
  name        = "Dev-security-group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.Dev.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dev-security-group"
  }
}
resource "aws_instance" "Dev" {
  ami           = "ami-079f3a0174060175c"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.Dev.id]
  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo service httpd start
echo "Hello World" | sudo tee /var/www/html/index.html
EOF

  tags = {
    Name = "Dev-instance"
  }
}
