import boto3
import os
from PIL import Image
import os

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('image_uploads')
#OPTIMIZED_BUCKET = os.environ['OPTIMIZED_BUCKET']
OPTIMIZED_BUCKET = "image-optimizer-optimized"

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key    = record['s3']['object']['key']

        print(f"Optimizing: {key}")

        tmp_path = f"/tmp/{os.path.basename(key)}"
        s3.download_file(bucket, key, tmp_path)

        img = Image.open(tmp_path)
        optimized_path = f"/tmp/optimized-{os.path.basename(key)}"
        img.save(optimized_path, "WEBP", quality=80)

        optimized_key = f"{os.path.splitext(key)[0]}.webp"
        
        print(f"Uploading {optimized_path} to bucket {OPTIMIZED_BUCKET} with key {optimized_key}")

        #s3.upload_file(optimized_path, OPTIMIZED_BUCKET, optimized_key)
        s3.upload_file(optimized_path, OPTIMIZED_BUCKET, optimized_key)

        table.update_item(
            Key={"filename": key},
            UpdateExpression="SET #s = :s, optimized_url = :url",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={
                ":s": "optimized",
                ":url": f"CLOUDFRONT_URL/{optimized_key}"
            }
        )
