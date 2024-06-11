data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_ml_lts" {
  long_term_support = true
  ml                = true
}

resource "databricks_cluster" "single_node_cluster" {
  cluster_name            = "single-node-cluster"
  spark_version           = data.databricks_spark_version.latest_ml_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 10
  num_workers             = 0
  data_security_mode      = "SINGLE_USER"
  single_user_name        = var.single_user_cluster_user_name

  spark_conf = {
    "spark.databricks.cluster.profile"                                              = "singleNode"
    "spark.master"                                                                  = "local[*]"
    format("fs.azure.account.key.%s.dfs.core.windows.net", var.poc_storage_account) = format("{{secrets/%s/poc-storage-account-key}}", databricks_secret_scope.nfl_secret_scope.name)
  }

  custom_tags = {
    "project"       = "nfl-play-by-play"
    "ResourceClass" = "SingleNode"
  }
}

resource "databricks_job" "nfl_pbp_pipeline" {
  name = "NFL Play by Play ETL Job"

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
    task_key            = "bronze"
    existing_cluster_id = databricks_cluster.single_node_cluster.id

    notebook_task {
      notebook_path   = "notebooks/bronze/BronzeIngestion"
      source          = "Git Provider"
      base_parameters = {
        storage_account_name   = var.poc_storage_account
        container_name         = var.poc_container_name
        catalog_name           = local.catalog_name
        bronze_database_name   = local.bronze_database_name
        raw_data_relative_path = local.scd_landing_path
      }
    }
  }

  task {
    task_key            = "silver"
    existing_cluster_id = databricks_cluster.single_node_cluster.id

    notebook_task {
      notebook_path   = "notebooks/silver/SilverCuration"
      source          = "Git Provider"
      base_parameters = {
        storage_account_name = var.poc_storage_account
        container_name       = var.poc_container_name
        catalog_name         = local.catalog_name
        bronze_database_name = local.bronze_database_name
        silver_database_name = local.silver_database_name
      }
    }

    depends_on {
      task_key = "bronze"
    }
  }

  task {
    task_key            = "gold-augment"
    existing_cluster_id = databricks_cluster.single_node_cluster.id

    notebook_task {
      notebook_path   = "notebooks/gold/GoldPublish_IndicatorAugs_and_Labels.py"
      source          = "Git Provider"
      base_parameters = {
        storage_account_name = var.poc_storage_account
        container_name       = var.poc_container_name
        catalog_name         = local.catalog_name
        gold_database_name   = local.gold_database_name
        silver_database_name = local.silver_database_name
      }
    }
    depends_on {
      task_key = "silver"
    }
  }
}
