import boto3
import os
import time
import uuid
import json

sqs = boto3.client("sqs", region_name=os.getenv("AWS_REGION", "us-east-1"))
s3 = boto3.client("s3", region_name=os.getenv("AWS_REGION", "us-east-1"))

SQS_QUEUE_URL = os.environ["SQS_QUEUE_URL"]
S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", 10))

def process_messages():
    while True:
        response = sqs.receive_message(
            QueueUrl=SQS_QUEUE_URL,
            MaxNumberOfMessages=5,
            WaitTimeSeconds=5
        )

        messages = response.get("Messages", [])
        for msg in messages:
            payload = msg["Body"]
            key = f"messages/{uuid.uuid4()}.json"
            s3.put_object(Bucket=S3_BUCKET_NAME, Key=key, Body=payload)

            sqs.delete_message(QueueUrl=SQS_QUEUE_URL, ReceiptHandle=msg["ReceiptHandle"])
            print(f"Saved message to {key}")

        time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    process_messages()
