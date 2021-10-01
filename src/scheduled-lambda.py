import boto3
import json, os


ECS_CLUSTER = os.getenv('ECS_CLUSTER') 
ECS_TASK_DEF = os.getenv('ECS_TASK_DEF') 
ECS_SUBNETS = json.loads(os.getenv('ECS_SUBNETS'))
ECS_SECURITY_GROUP = os.getenv('ECS_SECURITY_GROUP')
ECS_ASSIGN_PUBLIC_IP = os.getenv('ECS_ASSIGN_PUBLIC_IP', 'DISABLED')

ecs = boto3.client('ecs')


def is_task_running(cluster: str, task_def_name: str) -> bool:
    is_running = False

    # Get a list of all runnings tasks in the cluster. If
    # there are no running tasks, then return False.
    runnings_tasks_arn_list = ecs.list_tasks(
                                    cluster = cluster,
                                    desiredStatus = 'RUNNING',
                                    launchType = 'FARGATE'
                                )['taskArns']

    # If there are tasks running in the cluster, then check
    # each one to see if is the one we are attempting to start
    if len(runnings_tasks_arn_list):
        running_tasks_details_list = ecs.describe_tasks(
                                cluster = cluster,
                                tasks = runnings_tasks_arn_list
                            )['tasks']
        for task in running_tasks_details_list:
            is_running = True if task_def_name in task['group'] else False

    return is_running


def main():
    task_running = is_task_running(ECS_CLUSTER, ECS_TASK_DEF)

    if not task_running:
        print(f'Starting task: {ECS_TASK_DEF}', flush=True)
        ecs.run_task(
            cluster = ECS_CLUSTER,
            count = 1,
            launchType = 'FARGATE',
            taskDefinition = ECS_TASK_DEF,
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': ECS_SUBNETS ,
                    'securityGroups': [ ECS_SECURITY_GROUP ],
                    'assignPublicIp': ECS_ASSIGN_PUBLIC_IP
                }
            },
        )
    else:
        print(f'Task "{ECS_TASK_DEF}" is already running. Not starting new task.', flush=True)


def lambda_handler(event, context):
    main()

if __name__ == '__main__':
    main()