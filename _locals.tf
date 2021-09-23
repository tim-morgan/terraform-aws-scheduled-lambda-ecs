###########################################################
#                                                         #
#                Module Local Values                      #
#                                                         #
###########################################################   

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}



locals {
    lambda_name = "${var.environment}-${var.lambda_name}"
    filename    = "${path.module}/src/scheduled-lambda.zip"
}