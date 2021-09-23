###########################################################
#                                                         #
#                   Lambda                                #
#                                                         #
###########################################################             




resource "aws_lambda_function" "lambda" {
    depends_on = [
        aws_iam_role_policy.lambda_logs,
        aws_iam_role_policy.lambda,
    ]

    function_name       = local.lambda_name   
    filename            = local.filename      



    description = var.lambda_description   
    handler     = "scheduled-lambda.lambda_handler"     
    role        = aws_iam_role.lambda.arn
    runtime     = var.lambda_runtime       
    timeout     = var.lambda_timeout       
    memory_size = var.lambda_memory_size   

    source_code_hash = filebase64sha256(local.filename) 

    # dynamic "environment" {
    #     for_each = var.lambda_environment == null ? [] : [ var.lambda_environment ]

    #     content {
    #         variables = environment.value
    #     }
    # }

    tags = {
        Service     = var.service     
        Contact     = var.contact     
        Environment = var.environment 
        Project     = var.project     
    }
}