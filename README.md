# nfl-play-by-play

## Overview
This project is an example of a data product leveraging a medallion lakehouse architecture with Batch Ingestion directed via Databricks Notebooks.

The companion git repo hosting the notebooks is located here: https://github.com/King-AK/nfl-play-by-play-dbx-git. This repo directly interfaces with Databricks through the Repos functionality so that version controlled development can occur directly in the Databricks UI.

Dataset: [NFL Play-by-Play](https://www.kaggle.com/datasets/maxhorowitz/nflplaybyplay2009to2016)
Dataset descripition from Kaggle:
> The dataset made available on Kaggle contains all the regular season plays from the 2009-2016 NFL seasons. The dataset has 356,768 rows and 100 columns. Each play is broken down into great detail containing information on: game situation, players involved, results, and advanced metrics such as expected point and win probability values. Detailed information about the dataset can be found at the following web page, along with more NFL data: https://github.com/ryurko/nflscrapR-data.

## Terraform Deploy
The pipeline can be deployed to Azure using Terraform with the following commands after the project has been set up with the `databricks_poc` repo
```bash
cd terraform
terraform init
terraform apply -auto-approve -var-file=environment/poc.tfvars \
  -var='databricks_workspace_resource_id=<DATABRICKS-WORKSPACE-RESOURCE-ID>' \
  -var='databricks_workspace_url=<DATABRICKS-WORKSPACE-URL>' \
  -var='poc_storage_account_key=<STORAGE-ACCOUNT-KEY>' \
  -var='git_token=<GIT_TOKEN>'
```

## Terraform Destroy
The pipeline can be destroyed with the following command:
```bash
terraform destroy -auto-approve -var-file=environment/poc.tfvars \
  -var='databricks_workspace_resource_id=<DATABRICKS-WORKSPACE-RESOURCE-ID>' \
  -var='databricks_workspace_url=<DATABRICKS-WORKSPACE-URL>' \
  -var='poc_storage_account_key=<STORAGE-ACCOUNT-KEY>' \
  -var='git_token=<GIT_TOKEN>'
 
```

