variable "poc_storage_account" {}
variable "poc_container_name" {}
variable "poc_resource_group" {}
variable "poc_location" {}
variable "git_username" {}
variable "git_provider" {}
variable "databricks_repo_url" {}
variable "databricks_workspace_resource_id" {}
variable "databricks_workspace_url" {}
variable "poc_storage_account_key" {
  type      = string
  sensitive = true
}
variable "git_token" {
  type      = string
  sensitive = true
}
variable "single_user_cluster_user_name" {
  type      = string
  sensitive = true
}