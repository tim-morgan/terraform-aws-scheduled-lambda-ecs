###########################################################
#                                                         #
#                   Demo Lambda                           #
#                                                         #
###########################################################      


module "scheduled-lambda-function" {
    source = "../"

    lambda_name             = "scheduled-demo"
    lambda_description      = "Lambda to demo scheduling a lambda function."
    environment             = "dev"

    service                 = "Lambda demo"
    project                 = "demo"
    contact                 = "myemail@example.com"

    schedule_expression     = "rate(30 minutes)"

    # Required from ECS deployment
    ecs_cluster_name            = aws_ecs_cluster.example_cluster.name
    ecs_task_definition_family  = aws_ecs_task_definition.example_task.family
    ecs_task_execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}





