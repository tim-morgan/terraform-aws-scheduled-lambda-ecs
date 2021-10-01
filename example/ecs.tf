###########################################################
#                                                         #
#                         ECR                             #
#                                                         #
###########################################################

resource "aws_ecr_repository" "test-repo" {
    name                 = "test-repo"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration {
        scan_on_push = true
    }
}


###########################################################
#                                                         #
#                  Network Configuration                  #
#                                                         #
###########################################################


module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "3.0.0"

    name = "${local.service}-main" 
    cidr = "10.10.0.0/16"
    azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
    private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
    public_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
}


###########################################################
#                                                         #
#                  ECS Cluster                            #
#                                                         #
###########################################################

resource "aws_ecs_cluster" "example_cluster" {
    name = "example-cluster"
}





###########################################################
#                                                         #
#                  ECS Service                            #
#                                                         #
###########################################################


resource "aws_ecs_service" "example_service" {
    name = "example-service"
    cluster = aws_ecs_cluster.example_cluster.id
    task_definition = aws_ecs_task_definition.example_task.arn
    launch_type = "FARGATE"
    
    network_configuration {
        #security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = module.vpc.private_subnets
        assign_public_ip = false
    }
    
    lifecycle {
        ignore_changes = [desired_count]
    }
}



###########################################################
#                                                         #
#                  ECS Task Definition                    #
#                                                         #
###########################################################

resource "aws_ecs_task_definition" "example_task" {
    family = "example_task"
    requires_compatibilities = ["FARGATE"]
    cpu       = 256
    memory    = 512
    network_mode             = "awsvpc"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = jsonencode(local.container_definition_config)
}


###########################################################
#                                                         #
#                  ECS Container Definition               #
#                                                         #
###########################################################

locals {
    container_definition_config = [{
        name = "example_container"
        image = "730241096264.dkr.ecr.us-east-2.amazonaws.com/test-repo:latest"
    }]
}



###########################################################
#                                                         #
#                  IAM                                    #
#                                                         #
###########################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "apisvc_ecsTaskExecutionRole_secrets" {
    statement {
        effect    = "Allow"
        actions   = [ "ssm:GetParameters" ]
        resources = [ "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*" ]
    }
    statement {
        effect    = "Allow"
        actions   = [ "logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup" ]
        resources = [ "*" ]
    }
    /*statement {
        effect    = "Allow"
        actions   = [ "kms:Decrypt" ]
        resources = [ local.deploy_key_arn ]
    }*/
}


resource "random_id" "random" {
    byte_length = 4
}


# Resources
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole-${random_id.random.hex}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy" "apisvc_ecsTaskExecutionRole_secrets" {
    name = "secrets-role"
    role        = aws_iam_role.ecs_task_execution_role.id
    policy      = data.aws_iam_policy_document.apisvc_ecsTaskExecutionRole_secrets.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}