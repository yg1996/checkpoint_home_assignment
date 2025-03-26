import boto3
import os
import time
import uuid
import json
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Read and log environment variables for debugging
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
SQS_QUEUE_URL = os.environ.get("SQS_QUEUE_URL")
S3_BUCKET_NAME = os.environ.get("S3_BUCKET_NAME")
POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", 10))

logger.debug(f"AWS_REGION: {AWS_REGION}")
logger.debug(f"SQS_QUEUE_URL: {SQS_QUEUE_URL}")
logger.debug(f"S3_BUCKET_NAME: {S3_BUCKET_NAME}")
logger.debug(f"POLL_INTERVAL: {POLL_INTERVAL}")

sqs = boto3.client("sqs", region_name=AWS_REGION)
s3 = boto3.client("s3", region_name=AWS_REGION)

def process_messages():
    while True:
        try:
            response = sqs.receive_message(
                QueueUrl=SQS_QUEUE_URL,
                MaxNumberOfMessages=5,
                WaitTimeSeconds=5
            )
            logger.debug(f"Received SQS response: {json.dumps(response)}")
        except Exception as e:
            logger.error(f"Error receiving messages from SQS: {e}")
            time.sleep(POLL_INTERVAL)
            continue

        messages = response.get("Messages", [])
        if not messages:
            logger.debug("No messages received from SQS")
        for msg in messages:
            try:
                payload = msg["Body"]
                key = f"messages/{uuid.uuid4()}.json"
                s3.put_object(Bucket=S3_BUCKET_NAME, Key=key, Body=payload)
                logger.info(f"Saved message to S3 with key: {key}")
                sqs.delete_message(QueueUrl=SQS_QUEUE_URL, ReceiptHandle=msg["ReceiptHandle"])
                logger.debug("Deleted message from SQS")
            except Exception as e:
                logger.error(f"Error processing message: {e}")

        time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    logger.info("Starting worker process")
    process_messages()
