import boto3

s3 = boto3.client("s3")

BUCKET_NAME = "data-pipeline-final-demo"  
REGION = "us-east-2"

# Create bucket 

    s3.create_bucket(
        Bucket=BUCKET_NAME,
        CreateBucketConfiguration={"LocationConstraint": REGION}
    )

# Create prefixes
prefixes = [
    "raw/",
    "raw/taxizone/",
    "raw/trips/",
    "validated/",
    "validated/taxizone/",
    "validated/trips/",
    "curated/",
    "curated/trips/",
    "quarantine/",
    "quarantine/trips/"
]

for prefix in prefixes:
    s3.put_object(Bucket=BUCKET_NAME, Key=prefix)

# Upload Taxi Zone CSV
s3.upload_file(
    "TaxiZoneLookup.csv",
    BUCKET_NAME,
    "raw/taxizone/TaxiZoneLookup.csv"
)

# Upload Trips Parquet
s3.upload_file(
    "yellow_tripdata.parquet",
    BUCKET_NAME,
    "raw/trips/yellow_tripdata.parquet"
)
