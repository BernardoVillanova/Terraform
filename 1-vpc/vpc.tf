resource "aws_vpc" "Main" {
  cidr_block = cidrsubnet("10.0.0.0/16", 4, var.region_number[data.aws_availability_zone.example.region])
}

 resource "aws_internet_gateway" "IGW" {    
    vpc_id =  aws_vpc.Main.id               
 }

data "aws_availability_zone" "example" {
  name = "sa-east-1a"
}

 resource "aws_subnet" "publicsubnets" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = cidrsubnet(aws_vpc.Main.cidr_block, 4, var.az_number[data.aws_availability_zone.example.name_suffix])
  availability_zone = "sa-east-1a"
  }

  resource "aws_subnet" "privatesubnets" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = cidrsubnet(aws_vpc.Main.cidr_block, 2, var.az_number[data.aws_availability_zone.example.name_suffix])
  availability_zone = "sa-east-1b"
  }

 resource "aws_route_table" "PublicRT" {    
    vpc_id =  aws_vpc.Main.id
         route {
    cidr_block = "0.0.0.0/0"               
    gateway_id = aws_internet_gateway.IGW.id
     }
 }

 resource "aws_route_table" "PrivateRT" {   
   vpc_id = aws_vpc.Main.id
   route {
   cidr_block = "0.0.0.0/0"             
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
 }

 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }

 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrivateRT.id
 }
 resource "aws_eip" "nateIP" {
   vpc   = true
 }

 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.publicsubnets.id
 }

resource "aws_security_group" "allow_tls" {
  vpc_id      = aws_vpc.Main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

## Load Balancer
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["hardcore"] #try a var here
  subnets          = ["hardcode", "hardcore"] # and a var here too

  enable_deletion_protection = false

  access_logs {
    bucket  = "simple-bucket-for-application-archi"
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

## ecs-fargate & task definition

resource "aws_ecs_cluster" "cluster" {
  name = "example-ecs-cluster"
}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    {
      name      = "second"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [sa-east-1a, sa-east-1b]"
  }
}

resource "aws_ecs_service" "example" {
  name            = "test"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 3
}

## RDS

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}