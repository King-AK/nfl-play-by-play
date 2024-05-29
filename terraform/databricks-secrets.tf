resource "databricks_secret_scope" "nfl_secret_scope" {
  name = "nfl_secret_scope"
}

resource "databricks_secret" "storage_account_key" {
  key          = "poc-storage-account-key"
  string_value = var.poc_storage_account_key
  scope        = databricks_secret_scope.nfl_secret_scope.id
}
