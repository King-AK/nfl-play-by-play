locals {
  # ABFSS root path
  abfss_root_path = format("abfss://%s@%s.dfs.core.windows.net", var.poc_container_name, var.poc_storage_account)

  # Landing paths
  landing_root     = "landing"
  scd_landing_path = format("%s/nfl_play_by_play", local.landing_root)

  # Delta DB paths
  bronze_delta_db_path     = format("%s/bronze", local.abfss_root_path)
  silver_delta_db_path     = format("%s/silver", local.abfss_root_path)
  gold_delta_db_path       = format("%s/gold", local.abfss_root_path)
  # Delta Table paths
  bronze_nflpbp_table_path = format("%s/nfl_play_by_play", local.bronze_delta_db_path)

  # Unity Catalog
  catalog_name         = "nfl-play-by-play-project"
  bronze_database_name = "bronze"
  silver_database_name = "silver"


}
