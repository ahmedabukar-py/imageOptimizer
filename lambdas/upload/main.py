import json
import boto3
import base64
from datetime import datetime

# Initialize clients
s3 = boto3.client('s3')
dynamodb = boto3.client('dynamodb')

# Constants
ORIGINAL_BUCKET = 'image-optimizer-originals'
METADATA_TABLE = 'image_uploads'

def lambda_handler(event, context):
    try:
        # Parse the body of the request
        body = json.loads(event['body'])
        filename = body['filename']
        data = body['data']  # base64 encoded image
        email = body['email'] 

        # Decode image data from base64
        image_bytes = base64.b64decode(data)

        # Upload image to S3 bucket
        s3.put_object(
            Bucket=ORIGINAL_BUCKET,
            Key=filename,
            Body=image_bytes,
            ContentType='image/jpeg'  # This can be dynamic based on file extension
        )

        # Get current UTC time for the upload_time field
        upload_time = datetime.utcnow().isoformat()

        # Save metadata to DynamoDB
        dynamodb.put_item(
            TableName=METADATA_TABLE,
            Item={
                'filename': {'S': filename},
                'status': {'S': 'pending'},  # Mark the status as 'pending' upon upload
                'upload_time': {'S': upload_time},
                'email': {'S': email}
            }
        )

        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({'message': f'{filename} uploaded successfully'})
        }

    except Exception as e:
        # Return error response in case of failure
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
