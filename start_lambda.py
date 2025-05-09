import boto3
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_ids = os.environ['INSTANCE_IDS'].split(',')
    ec2.start_instances(InstanceIds=instance_ids)
    print(f"Started instances: {instance_ids}")