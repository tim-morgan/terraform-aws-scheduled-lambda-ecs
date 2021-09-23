###########################################################
#                                                         #
#                     Cloudwatch Logs                     #
#                                                         #
###########################################################  



resource "aws_cloudwatch_log_group" "lambda" {
    name              = "/aws/lambda/${local.lambda_name}"
    retention_in_days = var.lambda_log_retention_in_days

    tags = {
        Service             = var.service
        Contact             = var.contact
        DataClassification  = "Sensitive"
        Environment         = var.environment
        Project             = var.project
    }
}

