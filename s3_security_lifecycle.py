import boto3

s3 = boto3.client("s3")

BUCKET_NAME = "data-pipeline-final-demo"  

# 1️⃣ Enable SSE-KMS encryption
s3.put_bucket_encryption(
    Bucket=BUCKET_NAME,
    ServerSideEncryptionConfiguration={
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms"
                }
            }
        ]
    }
)

print("S3 encryption enabled (SSE-KMS)")

# 2️⃣ Enable versioning
s3.put_bucket_versioning(
    Bucket=BUCKET_NAME,
    VersioningConfiguration={
        "Status": "Enabled"
    }
)

print("S3 versioning enabled")

# 3️⃣ Add lifecycle policy (RAW only)
s3.put_bucket_lifecycle_configuration(
    Bucket=BUCKET_NAME,
    LifecycleConfiguration={
        "Rules": [
            {
                "ID": "raw-data-lifecycle",
                "Filter": {"Prefix": "raw/"},
                "Status": "Enabled",
                "Transitions": [
                    {
                        "Days": 30,
                        "StorageClass": "GLACIER"
                    }
                ],
                "Expiration": {
                    "Days": 365
                }
            }
        ]
    }
)

print("Lifecycle policy applied to raw data")

