resource "aws_instance" "frontend" {
  ami                    = "ami-0ec18f6103c5e0491"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0c82156e2901a05c4"]

  tags = {
    Name = "frontend"
  }
}

resource "aws_instance" "backend" {
  ami                    = "ami-0ec18f6103c5e0491"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0c82156e2901a05c4"]

  tags = {
    Name = "backend"
  }
}

resource "aws_instance" "mysql" {
  ami                    = "ami-0ec18f6103c5e0491"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["sg-0c82156e2901a05c4"]

  tags = {
    Name = "mysql"
  }
}