###########################################################  
#                                                         #
#                      IAM/Roles                          #
#                                                         #
########################################################### 


data "aws_iam_policy_document" "lambda_assume_role" {
    statement {
        effect  = "Allow"
        actions = [ "sts:AssumeRole" ]
        principals {
            type        = "Service"
            identifiers = [ "lambda.amazonaws.com" ]
        }
    }
}

data "aws_iam_policy_document" "lambda_logs" {
    statement {
        effect = "Allow"
        actions = [
            "logs:Describe*",
            "logs:List*",
        ]
        resources = [ "*" ]
    }

    statement {
        effect = "Allow"
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
        ]
        resources = [ "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_name}:*" ]
    }
}

data "aws_iam_policy_document" "scheduled_lambda" {
    # statement {
    #     effect    = "Allow"
    #     actions   = [ "ssm:GetParametersByPath" ]
    #     resources = [ "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}-splunkLogs/*" ]
    # }

    statement {
        effect    = "Allow"
        actions   = [ "ecs:ListTasks", "ecs:DescribeTasks" ]
        resources = [ "*" ]
    }

    statement {
        effect    = "Allow"
        actions   = [ "ecs:RunTask" ]
        resources = [ "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/${var.ecs_task_definition_family}" ]
    }

    statement {
        effect    = "Allow"
        actions   = [ "iam:PassRole" ]
        resources = [ var.ecs_role_arns ]
    }
}



resource "aws_iam_role" "lambda" {
    name_prefix = "${var.project}-lambda-"
    path        = "/service-role/"
    description = "Lambda ${local.lambda_name} role"

    assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}
resource "aws_iam_role_policy" "lambda_logs" {
    name_prefix = "logs-"
    role        = aws_iam_role.lambda.id
    policy      = data.aws_iam_policy_document.lambda_logs.json
}

resource "aws_iam_role_policy" "lambda" {
    name_prefix = "lambda-"
    role        = aws_iam_role.lambda.id
    policy      = data.aws_iam_policy_document.scheduled_lambda.json
}