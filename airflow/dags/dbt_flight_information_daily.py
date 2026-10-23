"""
DAG to run dbt project with on-demand date processing.

This DAG:
1. Accepts a mandatory processing_date parameter when triggered
2. Runs dbt with that date as processing_date
3. Updates the checkpoint after successful run
"""

from datetime import datetime, timedelta
import subprocess
import os
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.models import Variable
from airflow.models.param import Param

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

# Paths
DBT_PROJECT_PATH = '/opt/airflow/dbt_project'
CHECKPOINT_VAR = 'dbt_last_processed_date'


def run_dbt(**context):
    """
    Run dbt with the processing_date from DAG params.
    First installs dbt-snowflake if not present, then runs dbt.
    """
    processing_date = context['params']['processing_date']
    
    if not processing_date:
        raise Exception("No processing_date provided in params")
    
    print(f"Running dbt for processing_date: {processing_date}")
    
    # Install dbt-snowflake if not already installed
    try:
        import dbt
        print("dbt is already installed")
    except ImportError:
        print("Installing dbt-snowflake...")
        subprocess.run(
            ["pip", "install", "dbt-snowflake==1.7.0", "--quiet"],
            check=True
        )
        print("dbt-snowflake installed successfully")
    
    # Snowflake credentials are loaded from environment variables (via .env file)
    env = os.environ.copy()
    
    # Run dbt
    dbt_vars = f'{{"processing_date": "{processing_date}"}}'
    cmd = [
        "dbt", "run",
        "--project-dir", DBT_PROJECT_PATH,
        "--profiles-dir", DBT_PROJECT_PATH,
        "--vars", dbt_vars
    ]
    
    print(f"Running command: {' '.join(cmd)}")
    
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        env=env,
        cwd=DBT_PROJECT_PATH
    )
    
    print("STDOUT:")
    print(result.stdout)
    
    if result.stderr:
        print("STDERR:")
        print(result.stderr)
    
    if result.returncode != 0:
        raise Exception(f"dbt run failed with return code {result.returncode}")
    
    print(f"dbt run completed successfully for {processing_date}")
    return processing_date


def update_checkpoint(**context):
    """
    Update the checkpoint with the successfully processed date.
    """
    processed_date = context['params']['processing_date']
    
    if processed_date:
        Variable.set(CHECKPOINT_VAR, processed_date)
        print(f"Checkpoint updated to: {processed_date}")
    else:
        print("No date to update in checkpoint")


# Define the DAG
with DAG(
    'dbt_flight_information_daily',
    default_args=default_args,
    description='Run dbt project with on-demand date processing',
    schedule=None,  # On-demand only
    start_date=datetime(2025, 10, 1),
    catchup=False,
    tags=['dbt', 'flight_information'],
    params={
        'processing_date': Param(
            default=None,
            type=['null', 'string'],
            format='date',
            description='Processing date in YYYY-MM-DD format (required)',
        ),
    },
    render_template_as_native_obj=True,
) as dag:
    
    # Task 1: Run dbt with the processing_date
    run_dbt_task = PythonOperator(
        task_id='run_dbt',
        python_callable=run_dbt,
        provide_context=True,
    )
    
    # Task 2: Update checkpoint after successful dbt run
    update_checkpoint_task = PythonOperator(
        task_id='update_checkpoint',
        python_callable=update_checkpoint,
        provide_context=True,
    )
    
    # Define task dependencies
    run_dbt_task >> update_checkpoint_task
