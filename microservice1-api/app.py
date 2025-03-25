from flask import Flask, request, jsonify
import boto3
import os
import time
from botocore.exceptions import ClientError

app = Flask(__name__)

AWS_REGION = os.getenv("AWS_REGION", "us-west-1")
ssm = boto3.client("ssm", region_name=AWS_REGION)
sqs = boto3.client("sqs", region_name=AWS_REGION)

SQS_QUEUE_URL = os.environ["SQS_QUEUE_URL"]
TOKEN_PARAM_NAME = os.environ["TOKEN_PARAM_NAME"]

def get_token():
    try:
        response = ssm.get_parameter(Name=TOKEN_PARAM_NAME, WithDecryption=True)
        return response['Parameter']['Value']
    except ClientError as e:
        print(f"SSM error: {e}")
        return None

@app.route("/submit", methods=["POST"])
def submit():
    payload = request.get_json()

    if not payload or "token" not in payload or "data" not in payload:
        return jsonify({"error": "Missing 'token' or 'data' in request"}), 400

    expected_token = get_token()
    if payload["token"] != expected_token:
        return jsonify({"error": "Invalid token"}), 403

    # Validate email_timestream inside data
    try:
        timestream = int(payload["data"].get("email_timestream", 0))
        time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(timestream))  # Just to validate format
    except Exception:
        return jsonify({"error": "Invalid 'email_timestream'"}), 400

    # Send entire payload to SQS
    sqs.send_message(
        QueueUrl=SQS_QUEUE_URL,
        MessageBody=str(payload)
    )

    return jsonify({"message": "Payload accepted"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
