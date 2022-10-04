resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.publicsubnets.id

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  ami           = "ami-0897f5f4cf8105bdc" # sa-east-1
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}