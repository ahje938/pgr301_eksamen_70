import json
import base64
import boto3
import random
import os

# Opprette klient
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

def lambda_handler(event, context):
    # Lese fra json POST
    body = json.loads(event['body'])
    prompt = body.get('prompt', 'Default prompt')

    # Tilfeldig seed
    seed = random.randint(0, 2147483647)

    bucket_name = os.getenv("BUCKET_NAME")

    # Image path i bucket
    s3_image_path = f"70/titan_{seed}.png"

    # Forespørsel til modell
    native_request = {
        "taskType": "TEXT_IMAGE",
        "textToImageParams": {"text": prompt},
        "imageGenerationConfig": {
            "numberOfImages": 1,
            "quality": "standard",
            "cfgScale": 8.0,
            "height": 1024,
            "width": 1024,
            "seed": seed,
        }
    }

    # Forespørsel til Bedrock
    response = bedrock_client.invoke_model(
        modelId="amazon.titan-image-generator-v1",
        body=json.dumps(native_request)
    )
    
    model_response = json.loads(response["body"].read())
    base64_image_data = model_response["images"][0]

    # Dekode
    image_data = base64.b64decode(base64_image_data)

    # Last opp bildet til S3
    s3_client.put_object(Bucket=bucket_name, Key=s3_image_path, Body=image_data)

    return {
        'statusCode': 200,
        'body': json.dumps("Handling utført")
    }