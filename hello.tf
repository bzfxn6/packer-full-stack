locals {
  region = "us-east-1"
  account="730335296647"
}

provider "aws" {
  region = local.region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  
  // Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Define additional security group rules here if needed
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_attachment" {
  name       = "ecs_task_execution_role_attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecr_repository" "hello_world_repo" {
  name = "hello-world-repo"
}

# resource "aws_ecs_cluster" "hello_world_cluster" {
#   name = "hello-world-cluster"
# }

# resource "aws_ecs_task_definition" "hello_world_task" {
#   family                   = "hello-world-task"
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#   network_mode             = "awsvpc"

#   container_definitions = jsonencode([
#     {
#       name      = "hello-world-container"
#       image     = "hello-world:linux"
#       cpu       = 256
#       memory    = 512
#       essential = true
#     }
#   ])
# }

# resource "aws_ecs_service" "hello_world_service" {
#   name            = "hello-world-service"
#   cluster         = aws_ecs_cluster.hello_world_cluster.id
#   task_definition = aws_ecs_task_definition.hello_world_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets         = [aws_subnet.subnet_a.id]
#     security_groups = [aws_security_group.my_security_group.id]
#     assign_public_ip = true
#   }
# }
