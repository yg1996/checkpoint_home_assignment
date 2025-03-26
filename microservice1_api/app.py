from flask import Flask, request, jsonify
import boto3
import os
import time
import logging
from botocore.exceptions import ClientError

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Read and log environment variables for debugging
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
SQS_QUEUE_URL = os.environ.get("SQS_QUEUE_URL")
TOKEN_PARAM_NAME = os.environ.get("TOKEN_PARAM_NAME")

logger.debug(f"AWS_REGION: {AWS_REGION}")
logger.debug(f"SQS_QUEUE_URL: {SQS_QUEUE_URL}")
logger.debug(f"TOKEN_PARAM_NAME: {TOKEN_PARAM_NAME}")

ssm = boto3.client("ssm", region_name=AWS_REGION)
sqs = boto3.client("sqs", region_name=AWS_REGION)

def get_token():
    try:
        response = ssm.get_parameter(Name=TOKEN_PARAM_NAME, WithDecryption=True)
        token_value = response['Parameter']['Value']
        logger.debug(f"Retrieved token from SSM: {token_value}")
        return token_value
    except ClientError as e:
        logger.error(f"SSM error: {e}")
        return None

@app.route("/health", methods=["GET"])
def health():
    logger.info("Health check called")
    return jsonify({"status": "ok"}), 200

@app.route("/submit", methods=["POST"])
def submit():
    logger.info("Received /submit request")
    payload = request.get_json()
    logger.debug(f"Payload received: {payload}")

    if not payload or "token" not in payload or "data" not in payload:
        logger.warning("Missing 'token' or 'data' in request")
        return jsonify({"error": "Missing 'token' or 'data' in request"}), 400

    expected_token = get_token()
    logger.debug(f"Expected token: {expected_token}")
    if payload["token"] != expected_token:
        logger.warning("Invalid token provided")
        return jsonify({"error": "Invalid token"}), 403

    # Validate email_timestream inside data
    try:
        timestream = int(payload["data"].get("email_timestream", 0))
        formatted_time = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(timestream))
        logger.debug(f"Validated email_timestream: {formatted_time}")
    except Exception as e:
        logger.error(f"Invalid 'email_timestream': {e}")
        return jsonify({"error": "Invalid 'email_timestream'"}), 400

    # Send entire payload to SQS
    try:
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=str(payload)
        )
        logger.info("Payload sent to SQS successfully")
    except Exception as e:
        logger.error(f"Error sending message to SQS: {e}")
        return jsonify({"error": "Failed to send message to SQS"}), 500

    return jsonify({"message": "Payload accepted"}), 200

if __name__ == "__main__":
    logger.info("Starting microservice1 on port 5000")
    app.run(host="0.0.0.0", port=5000)
