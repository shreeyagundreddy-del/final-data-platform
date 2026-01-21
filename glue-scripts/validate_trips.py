import sys
from pyspark.sql import SparkSession
from awsglue.utils import getResolvedOptions

# Read arguments passed from Glue job
args = getResolvedOptions(sys.argv, ["raw_path", "validated_path"])

spark = SparkSession.builder.getOrCreate()

# Read raw data
df = spark.read.parquet(args["raw_path"])

# Basic validation logic
df_valid = (
    df.dropna()              # remove rows with nulls
      .dropDuplicates()      # remove duplicate rows
)

# Write to validated zone
df_valid.write.mode("overwrite").parquet(args["validated_path"])
