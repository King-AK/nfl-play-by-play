resource "azurerm_storage_blob" "csv_example" {
  name                   = format("%s/file_1.csv", local.scd_landing_path)
  storage_account_name   = var.poc_storage_account
  storage_container_name = var.poc_container_name
  type                   = "Block"
  source                 = "../test_data/nfl_play_by_play_2009_2018.csv"
}
