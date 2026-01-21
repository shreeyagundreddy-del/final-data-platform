import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

job = Job(glueContext)
job.init(args['JOB_NAME'], args)


# Read validated data
df = spark.read.parquet("s3://data-pipeline-final-demo/validated/trips/")

# Example curation (keep it simple)
curated_df = (
    df
    .withColumnRenamed("pickup_datetime", "pickup_ts")
    .withColumnRenamed("dropoff_datetime", "dropoff_ts")
)

# Write curated data
curated_df.write.mode("overwrite").parquet(
    "s3://data-pipeline-final-demo/curated/trips/"
)

job.commit()
