resource "aws_instance" "web" {
  ami           = ami-0ec18f6103c5e0491
  instance_type = "t2.micro"

  tags = {
    Name = "my_tf_instance"
  }
}