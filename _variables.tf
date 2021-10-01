###########################################################
#                                                         #
#                Module Input Variables                   #
#                                                         #
###########################################################    



variable "lambda_name" {
    type        = string
    description = "The lambda function's name."
}

variable "lambda_description" {
    type        = string
    description = "Description of the lambda function."
}

variable "environment" {
    type        = string
    description = "Deployment environment. prod, test, dev, etc."
    default     = ""
}

variable "service" {
    type        = string
    description = "Service name (match Service Catalog where possible)."
}

variable "contact" {
    type        = string
    description = "Service email address."
}

variable "project" {
    type        = string
    description = "Name for the infrastructure project. This will be included in resource names and tags where possible."
}


###########################################################
#                        ECS                              #
###########################################################

variable "ecs_cluster_name" {
    type = string 
    description = "The ECS Cluster name for the task to be deployed to."
}

variable "ecs_task_definition_family" {
    type        = string
    description = "The ECS Task Definition family name (without version number)."
}

variable "ecs_task_execution_role_arn" {
    type        = string
    description = "The ECS task execurtion role arn."
}

###########################################################
#                   ECS Networking                        #
###########################################################






###########################################################
#                Lambda Configuration                     #
###########################################################

variable "schedule_expression" {
    type        = string
    description = "EventBridge schedule expression. ex: rate(5 minutes)"
}

variable "lambda_runtime" {
    type        = string
    description = "Lambda runtime. python3.8, nodejs10.x, etc"
    default     = "python3.8"
}

variable "lambda_timeout" {
    type        = number
    description = "Lambda function timeout in seconds."
    default     = 30
}

variable "lambda_memory_size" {
    type        = number
    description = "Lambda function's maximum memory usage in mb."
    default     = 128
}

variable "lambda_log_retention_in_days" {
    type        = number
    description = "Number of days to retain log streams."
    default     = 30
}