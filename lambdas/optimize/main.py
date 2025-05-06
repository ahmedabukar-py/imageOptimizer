import os
import boto3
from PIL import Image
import os.path

from datetime import datetime, timedelta

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Environment variables
OPTIMIZED_BUCKET = os.environ['OPTIMIZED_BUCKET']
DDB_TABLE = os.environ['DDB_TABLE']

table = dynamodb.Table(DDB_TABLE)

def generate_presigned_url(key, expires_in=3600):
    return s3.generate_presigned_url(
        'get_object',
        Params={'Bucket': OPTIMIZED_BUCKET, 'Key': key},
        ExpiresIn=expires_in
    )

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        filename = os.path.basename(key)

        print(f"Optimizing {key}")

        # Download original image
        tmp_path = f"/tmp/{filename}"
        s3.download_file(bucket, key, tmp_path)

        # Optimize and convert to WebP
        img = Image.open(tmp_path)
        optimized_filename = f"{os.path.splitext(filename)[0]}.webp"
        optimized_path = f"/tmp/{optimized_filename}"
        img.save(optimized_path, "WEBP", quality=80)

        # Upload to optimized bucket
        s3.upload_file(optimized_path, OPTIMIZED_BUCKET, optimized_filename)

        # Generate pre-signed URL for the optimized image
        presigned_url = generate_presigned_url(optimized_filename)

        # Update DynamoDB with status and pre-signed URL
        table.update_item(
            Key={'filename': filename},
            UpdateExpression="SET #s = :s, optimized_url = :url",
            ExpressionAttributeNames={'#s': 'status'},
            ExpressionAttributeValues={
                ':s': 'optimized',
                ':url': presigned_url
            }
        )

        print(f"Image {filename} optimized and updated with presigned URL.")

    return {
        'statusCode': 200,
        'body': 'Optimization complete!'
    }