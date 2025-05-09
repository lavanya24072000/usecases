import boto3
import os
 
def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_id = os.environ.get('INSTANCE_ID')
 
    if not instance_id:
        return {
            'statusCode': 400,
            'body': 'Environment variable INSTANCE_ID is not set'
        }
 
    try:
        ec2.stop_instances(InstanceIds=[instance_id])
        return {
            'statusCode': 200,
            'body': f'Successfully stopped instance {instance_id}'
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Error stopping instance: {str(e)}'
        }
 
 