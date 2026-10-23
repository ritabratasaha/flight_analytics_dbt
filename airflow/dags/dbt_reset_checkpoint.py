"""
Utility DAG to reset the dbt processing checkpoint and truncate all models.
Trigger manually to start fresh from the first date in CSV.
"""

import os
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable

CHECKPOINT_VAR = 'dbt_last_processed_date'

# Models to truncate (only incremental tables, not views or full-refresh tables)
INCREMENTAL_MODELS = [
    'staging.stg_bookings',
    'staging.stg_tickets',
    'staging.stg_flights',
    'staging.stg_boarding_passes',
    'intermediate.int_ticket_snapshot',
]


def reset_checkpoint():
    """Delete the checkpoint variable to start fresh."""
    try:
        Variable.delete(CHECKPOINT_VAR)
        print("Checkpoint reset. Next run starts from first date.")
    except KeyError:
        print("Checkpoint was already empty.")


def truncate_models():
    """Truncate all incremental models in Snowflake."""
    import subprocess
    
    # Install snowflake-connector if not present
    try:
        import snowflake.connector
    except ImportError:
        subprocess.run(["pip", "install", "snowflake-connector-python", "--quiet"], check=True)
        import snowflake.connector
    
    conn = snowflake.connector.connect(
        account=os.environ['SNOWFLAKE_ACCOUNT'],
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        role=os.environ['SNOWFLAKE_ROLE'],
        warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
        database=os.environ['SNOWFLAKE_DATABASE'],
    )
    
    cursor = conn.cursor()
    for model in INCREMENTAL_MODELS:
        try:
            cursor.execute(f"TRUNCATE TABLE IF EXISTS {model}")
            print(f"Truncated: {model}")
        except Exception as e:
            print(f"Skipped {model}: {e}")
    
    cursor.close()
    conn.close()
    print("All models truncated.")


with DAG(
    'dbt_reset_checkpoint',
    schedule=None,
    start_date=datetime(2025, 10, 1),
    catchup=False,
    tags=['dbt', 'utility'],
) as dag:
    
    reset_task = PythonOperator(
        task_id='reset_checkpoint',
        python_callable=reset_checkpoint,
    )
    
    truncate_task = PythonOperator(
        task_id='truncate_models',
        python_callable=truncate_models,
    )
    
    reset_task >> truncate_task
