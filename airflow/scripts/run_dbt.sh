#!/bin/bash
# Script to run dbt with a specific processing_date
# Usage: ./run_dbt.sh <processing_date>

set -e

PROCESSING_DATE=$1
DBT_PROJECT_DIR="/Users/risaha/Documents/projects/flight_information"

if [ -z "$PROCESSING_DATE" ]; then
    echo "Error: processing_date is required"
    exit 1
fi

echo "Running dbt for processing_date: $PROCESSING_DATE"

# Activate conda environment and run dbt
source /Users/risaha/miniconda3/etc/profile.d/conda.sh
conda activate dbtenv

cd "$DBT_PROJECT_DIR"
dbt run --vars "{\"processing_date\": \"$PROCESSING_DATE\"}"

echo "dbt run completed successfully for $PROCESSING_DATE"
