data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_job" "nfl_pbp_pipeline" {
  name = "NFL Play by Play ETL Job"

  job_cluster {
    job_cluster_key = "nfl_pbp_pipeline_cluster"
    new_cluster {
      num_workers   = 1
      spark_version = data.databricks_spark_version.latest_lts.id
      node_type_id  = data.databricks_node_type.smallest.id

      spark_conf = {
        format("fs.azure.account.key.%s.dfs.core.windows.net", var.poc_storage_account) = format("{{secrets/%s/poc-storage-account-key}}", databricks_secret_scope.nfl_secret_scope.name)
      }

    }
  }

  # dynamic "library" {
  #   for_each = ["langchain==0.0.239", "openai==0.27.8", "matplotlib==3.7.2"]
  #   content {
  #     pypi {
  #       package = library.value
  #     }
  #   }
  # }



  git_source {
    url      = var.databricks_repo_url
    provider = var.git_provider
    branch   = "main"
  }

  task {
    task_key        = "bronze"
    job_cluster_key = "nfl_pbp_pipeline_cluster"

    notebook_task {
      notebook_path = "notebooks/bronze/ingest"
      source        = "Git Provider"
      base_parameters = {
        storage_account_name = var.poc_storage_account
        container_name       = var.poc_container_name
      }
    }
  }

  dynamic "task" {
    for_each = ["PIT", "NE", "GB"]
    content {
      task_key = format("silver-%s", task.value)

      depends_on {
        task_key = "bronze"
      }

      job_cluster_key = "nfl_pbp_pipeline_cluster"

      notebook_task {
        notebook_path = "notebooks/silver/curate"
        source        = "Git Provider"
        base_parameters = {
          target_team          = task.value
          storage_account_name = var.poc_storage_account
          container_name       = var.poc_container_name
        }
      }
    }
  }
}
