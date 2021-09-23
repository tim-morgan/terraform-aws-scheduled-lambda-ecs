import boto3
import os


ECS_CLUSTER = os.getenv('ECS_CLUSTER', 'example-cluster') 
ECS_TASK_DEF = os.getenv('ECS_TASK_DEF', 'example_task')
ECS_SUBNETS = os.getenv('ECS_SUBNET', 'subnet-079e722e170867cd1')
ECS_SECURITY_GROUPS = os.getenv('ECS_SECURITY_GROUPS', 'sg-0b8fe032ea40d0380')
ECS_ASSIGN_PUBLIC_IP = os.getenv('ECS_ASSIGN_PUBLIC_IP', 'DISABLED')

ecs = boto3.client('ecs')



def get_running_tasks():
    runnings_tasks = ecs.list_tasks(
                        cluster = ECS_CLUSTER,
                        desiredStatus = 'RUNNING',
                        launchType = 'FARGATE'
                    )['taskArns']
    return runnings_tasks


def main():
    running_tasks = get_running_tasks()
    print(f'running_tasks: {len(running_tasks)}')

    if len(running_tasks) == 0:
        print('Starting task')
        ecs.run_task(
            cluster = ECS_CLUSTER,
            count = 1,
            launchType = 'FARGATE',
            taskDefinition = ECS_TASK_DEF,
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': [ ECS_SUBNETS ],
                    'securityGroups': [ ECS_SECURITY_GROUPS ],
                    'assignPublicIp': ECS_ASSIGN_PUBLIC_IP
                }
            },
        )
    else:
        print('Maximum number of tasks running.')


def lambda_handler(event, context):
    main()

if __name__ == '__main__':
    main()
