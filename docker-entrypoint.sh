#!/bin/bash

echo "Container is running!!!"


gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
mkdir -p /mnt/gcs_data
gcsfuse --key-file=$GOOGLE_APPLICATION_CREDENTIALS $GCS_BUCKET_NAME /mnt/gcs_data
echo 'GCS bucket mounted at /mnt/gcs_data'

mkdir -p /app/news_dataset_dvc
mkdir -p /app/news_dataset_dvc/llm-finetuning-data
mkdir -p /app/news_dataset_dvc/llm-rag-prompts
mkdir -p /app/news_dataset_dvc/stock-universe

mount --bind /mnt/gcs_data/dvc_store/llm-finetuning-data /app/news_dataset_dvc/llm-finetuning-data
mount --bind /mnt/gcs_data/dvc_store/llm-rag-prompts /app/news_dataset_dvc/llm-rag-prompts
mount --bind /mnt/gcs_data/dvc_store/stock-universe /app/news_dataset_dvc/stock-universe
echo 'Folders successfully bound to /app/news_dataset_dvc!'

pipenv shell
