# Data Versioning

For data versioning, everything will be run inside containers using Docker, except that you need to config your git in VM first before building the image. For Windows user, it's recommended that you use wsl ubuntu.

```
git config --global user.name "your_username"
git config --global user.email "your_email"
```

## Prerequisites
* Have the latest Docker installed

## Make sure we do not have any running containers and clear up an unused images
* Run `docker container ls`
* Stop any container that is running
* Run `docker system prune`
* Run `docker image ls`

### Clone the github repository
Your folder structure should look like this:
```
   |-data-versioning
   |-secrets
```

### Create a Data Store folder in GCS Bucket
- Go to `https://console.cloud.google.com/storage/browser`
- Go to the bucket `headline-scraper-bucket` (REPLACE WITH YOUR BUCKET NAME)
- Create a folder `dvc_store` inside the bucket
- Create a folder `stock-universe/`, `llm-rag-prompts/`, `llm-finetuning-data` inside the bucket 

## Run DVC Container
We will be using [DVC](https://dvc.org/) as our data versioning tool. DVC (Data Version Control) is an open-source, Git-based data science tool. It applies version control to machine learning development, make your repo the backbone of your project.

### Setup DVC Container Parameters
In order for the DVC container to connect to the GCS Bucket open the file `docker-shell.sh` and edit:
```
export GCS_BUCKET_NAME="headline-scraper-bucket" [REPLACE WITH YOUR BUCKET NAME]
export GCP_PROJECT="ac215-438007" [REPLACE WITH YOUR GCP PROJECT ID]
export GCP_ZONE="us-east1"
```

### Note: Addition of `docker-entrypoint.sh`
Note that we have added a new file called `docker-entrypoint.sh` to our development flow. A `docker-entrypoint.sh` is used to simplify some task when running containers such as:
* Helps with Initialization and Setup: 
   * The entrypoint file is used to perform necessary setup tasks when the container starts. 
   * It is a way to ensure that certain operations occur every time the container runs, regardless of the command used to start it.
* Helps with Dynamic Configuration:
   * It allows for dynamic configuration of the container environment based on runtime variables or mounted volumes. 
   * This is more flexible than hardcoding everything into the Dockerfile.

For this container we need to:
* Mount a GCS bucket to a volume mount in the container
* We then mount the folders in the bucket to the folders under "/app/"

### Run `docker-shell.sh`
- Make sure you are inside the `data-versioning` folder and open a terminal at this location
- For windows user, run "sudo apt-get install dos2unix" (then type in your password) and then "dos2unix docker-shell.sh", "dos2unix docker-entrypoint.sh" first.
- Run `sh docker-shell.sh`  

### Version Data using DVC
In this step we will start tracking the dataset using DVC

#### Initialize Data Registry
In this step we create a data registry using DVC

`dvc init -f`

#### Add Remote Registry to GCS Bucket (For Data)
`dvc remote add -d news_dataset_dvc gs://headline-scraper-bucket/dvc_store`

#### Add the dataset to registry
`dvc add news_dataset_dvc`

#### Push to Remote Registry
`dvc push`

You can go to your GCS Bucket folder `dvs_store` to view the tracking files


#### Update Git to track DVC 
Run this outside the container. 
- First run git status `git status`; if there's an issue try `git config --global --add safe.directory /app`
- Add changes `git add .`
- Commit changes `git commit -m 'dataset updates...'`
- Add a dataset tag `git tag -a 'dataset_v20' -m 'tag dataset'`
- Push changes `git push --atomic origin main dataset_v20`


### Download Data to view version
In this Step we will use Colab to view various version of the dataset
- Open [Colab Notebook](https://colab.research.google.com/drive/1RRQ1SlHq5lKK76R8LoQdi5LjCnND3jTq?usp=sharing)
- Follow instruction in the Colab Notebook

## Make changes to data

### Update bucket

#### Add the dataset (changes) to registry
`dvc add news_dataset_dvc`

#### Push to Remote Registry
`dvc push`

#### Update Git to track DVC changes (again remember this should be done outside the container)
- First run git status `git status`
- Add changes `git add .`
- Commit changes `git commit -m 'dataset updates...'`
- Add a dataset tag `git tag -a 'dataset_v21' -m 'tag dataset'`
- Push changes `git push --atomic origin main dataset_v21`


### Download Data to view version
In this Step we will use Colab to view the new version of the dataset
- Open [Colab Notebook](https://colab.research.google.com/drive/1RRQ1SlHq5lKK76R8LoQdi5LjCnND3jTq?usp=sharing)
- Follow instruction in the Colab Notebook to view `dataset_v21`


### 🎉 Congratulations we just setup and tested data versioning using DVC

## Docker Cleanup
To make sure we do not have any running containers and clear up an unused images
* Run `docker container ls`
* Stop any container that is running
* Run `docker system prune`
* Run `docker image ls`
