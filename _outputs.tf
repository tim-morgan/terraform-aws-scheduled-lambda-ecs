###########################################################
#                                                         #
#                Module Output Values                     #
#                                                         #
########################################################### 



output "lambda_function_name" {
    value = aws_lambda_function.lambda.function_name
}

output "lambda_arn" {
    value = aws_lambda_function.lambda.arn
}