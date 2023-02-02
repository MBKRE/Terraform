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
  associate_public_ip_address = true
  
  tags = {
    Name = "Dev-subnet"
  }
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

  tags = {
    Name = "Dev-security-group"
  }
}
resource "aws_instance" "Dev" {
  ami           = "ami-079f3a0174060175c"
  instance_type = "t2.micro"
  availability_zone = "us-east-1"
  vpc_security_group_ids = [aws_security_group.Dev.id]
  subnet_id     = aws_subnet.Dev.id

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
