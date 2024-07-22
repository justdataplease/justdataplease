import os
from dotenv import load_dotenv

projects = {
    'justfunctions': {
        "project_id": 'justfunctions',
        "dataset": 'eu',
        "location": 'eu',
        "bucket_path": 'justfunctions/bigquery-functions',
        "cloud_storage_directory": 'gs://justfunctions/bigquery-functions',
        "allow_private": False,
    }
}
