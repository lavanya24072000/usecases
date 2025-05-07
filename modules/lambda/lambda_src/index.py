Import boto3, os, io
From PIL import Image

S3 = boto3.client(‘s3’)
Sns = boto3.client(‘sns’)
DEST_BUCKET = os.environ[‘DEST_BUCKET’]
SNS_TOPIC_ARN = os.environ[‘SNS_TOPIC_ARN’]

Def lambda_handler(event, context):
    Bucket = event[‘Records’][0][‘s3’][‘bucket’][‘name’]
    Key    = event[‘Records’][0][‘s3’][‘object’][‘key’]

    Img_obj = s3.get_object(Bucket=bucket, Key=key)
    Img_data = img_obj[‘Body’].read()

    With Image.open(io.BytesIO(img_data)) as image:
        Resized = image.resize((100, 100))
        Buffer = io.BytesIO()
        Resized.save(buffer, format=image.format)
        Buffer.seek(0)
        S3.put_object(Bucket=DEST_BUCKET, Key=key, Body=buffer)

    Sns.publish(TopicArn=SNS_TOPIC_ARN, Message=f”Image resized: {key}”, Subject=”Resize Complete”)

    Return {“status”: “ok”}
