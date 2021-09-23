###########################################################
#                                                         #
#                   EventBridge Rules                     #
#                                                         #
###########################################################   


resource "aws_cloudwatch_event_rule" "lambda_scheduler" {
    name                = "${local.lambda_name}-lambda_scheduler"
    description         = "Runs a lambda function on a regular schedule."
    schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_scheduler" {
    arn  = aws_lambda_function.lambda.arn
    rule = aws_cloudwatch_event_rule.lambda_scheduler.id
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_scheduled_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.lambda_scheduler.arn
}