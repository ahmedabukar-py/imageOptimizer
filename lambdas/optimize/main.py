import os
import boto3
from PIL import Image
from datetime import datetime, timedelta

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
cf_client = boto3.client('cloudfront')

# Environment variables
OPTIMIZED_BUCKET = os.environ['OPTIMIZED_BUCKET']
DDB_TABLE = os.environ['DDB_TABLE']
CLOUDFRONT_DOMAIN = os.environ['CLOUDFRONT_DOMAIN']  # CloudFront domain name from Terraform output
KEY_PAIR_ID = os.environ['CLOUDFRONT_KEY_PAIR_ID']
PRIVATE_KEY = os.environ['CLOUDFRONT_PRIVATE_KEY']  # Store this securely

table = dynamodb.Table(DDB_TABLE)

from botocore.signers import CloudFrontSigner
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
import rsa

def rsa_signer(message):
    private_key = serialization.load_pem_private_key(
        PRIVATE_KEY.encode(), password=None, backend=default_backend()
    )
    return private_key.sign(message, rsa.pkcs1.PKCS1v15(), rsa.hashes.SHA1())

signer = CloudFrontSigner(KEY_PAIR_ID, rsa_signer)

def generate_signed_url(key, expires_in_seconds=3600):
    url = f"https://{CLOUDFRONT_DOMAIN}/{key}"
    expires = datetime.utcnow() + timedelta(seconds=expires_in_seconds)
    signed_url = signer.generate_presigned_url(url, date_less_than=expires)
    return signed_url

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

        # Generate CloudFront signed URL
        signed_url = generate_signed_url(optimized_filename)

        # Update DynamoDB
        table.update_item(
            Key={'filename': filename},
            UpdateExpression="SET #s = :s, optimized_url = :url",
            ExpressionAttributeNames={'#s': 'status'},
            ExpressionAttributeValues={
                ':s': 'optimized',
                ':url': signed_url
            }
        )

        print(f"Image {filename} optimized and updated with signed URL.")

    return {
        'statusCode': 200,
        'body': 'Optimization complete!'
    }
