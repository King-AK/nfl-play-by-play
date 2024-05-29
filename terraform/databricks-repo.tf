# Configure Git Connection
resource "databricks_git_credential" "git" {
  git_username          = var.git_username
  git_provider          = var.git_provider
  force                 = true
  personal_access_token = var.git_token
}

# Configure Databricks Repo
resource "databricks_repo" "repo" {
  url          = var.databricks_repo_url
  path         = "/Repos/databricks_poc/nfl-play-by-play-dbx-git"
  git_provider = var.git_provider
  depends_on = [
    databricks_git_credential.git
  ]
}
