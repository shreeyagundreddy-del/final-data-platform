import sys
import os
import json
import boto3
import psycopg2

SQL_FILES = [
    "01_create_schemas.sql",
    "02_create_raw_tables.sql",
    "03_transform_trips_base.sql",
    "05_dq_tests.sql",
    "04_dq_trip_validations.sql"
]

TMP_DIR = "/tmp/sql"

from awsglue.utils import getResolvedOptions

def get_db_secret(secret_name, region):
    sm = boto3.client("secretsmanager", region_name=region)
    resp = sm.get_secret_value(SecretId=secret_name)
    return json.loads(resp["SecretString"])

def main():
    args = getResolvedOptions(
        sys.argv,
        ["S3_BUCKET", "S3_SQL_PREFIX", "AWS_REGION"]
    )
    bucket = args["S3_BUCKET"]
    prefix = args["S3_SQL_PREFIX"].strip("/")
    region = args["AWS_REGION"]

    secret = get_db_secret("mdm/rds/postgres", region)

    os.makedirs(TMP_DIR, exist_ok=True)
    s3 = boto3.client("s3")

    for f in SQL_FILES:
        s3.download_file(bucket, f"{prefix}/{f}", f"{TMP_DIR}/{f}")

    conn = psycopg2.connect(
        host=secret["host"],
        port=secret["port"],
        dbname=secret["dbname"],
        user=secret["username"],
        password=secret["password"],
        sslmode="require",
    )
    conn.autocommit = True
    cur = conn.cursor()

    for f in SQL_FILES:
        with open(f"{TMP_DIR}/{f}") as fh:
            cur.execute(fh.read())

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
