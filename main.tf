#
# Import standardization module
#
module "std" {
  source =  "github.com/clearscale/tf-standards.git?ref=v1.0.0"

  prefix   = var.prefix
  client   = var.client
  project  = var.project
  accounts = [var.account]
  env      = var.env
  region   = var.region
  name     = var.name
  function = var.repo.name
}

#
# AWS CodeCommit repository
#
# data "aws_codecommit_repository" "this" {
#   count           = var.repo.create == false ? 1 : 0
#   repository_name = var.repo.name
# }
resource "aws_codecommit_repository" "this" {
  count           = var.repo.create == true ? 1 : 0
  repository_name = var.repo.name
  description     = var.repo.description
  default_branch  = var.repo.default_branch
  tags            = var.repo.tags
}