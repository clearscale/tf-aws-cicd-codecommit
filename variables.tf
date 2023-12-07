locals {
  project    = lower(replace(var.project, " ", "-"))
  account_id = lower(trimspace(replace(var.account.id,   "-", "")))

  repo_account = (var.repo.account == null
    ? var.account
    : var.repo.account
  )

  account_id_repo = ((
    local.repo_account != "*" &&
    local.repo_account != local.account_id
  )
    ? local.repo_account.id
    : data.aws_caller_identity.current.account_id
  )

  rex_arn = "arn:aws:([^:]+)?:([^:]+)?:([0-9]+)?:"
  ext_accounts = distinct([     # Grab all external account IDs from ARNs
    for arn in var.trusts : regex(local.rex_arn, arn)[2]
      if try(regex(local.rex_arn, arn)[2], local.account_id_repo) != local.account_id_repo
  ])

  iam_roles = distinct([        # Grab any IAM roles from the list of ARNs
    for arn in var.trusts : arn
      if startswith(arn, "arn:aws:iam:") && strcontains(arn, ":role/")
  ])

  s3_bucket_names = distinct([ # Grab any entries without ARNs and consider them S3 bucket names
    for arn in var.trusts : "arn:aws:s3:::${arn}"
      if startswith(arn, "arn:") == false
  ])

  s3_bucket_arns = distinct([  # Grab any S3 buckets from the list
    for arn in var.trusts : arn
      if startswith(arn, "arn:aws:s3:")
  ])

  kms_keys = distinct([         # Grab any KMS keys from the list
    for arn in var.trusts : arn
      if startswith(arn, "arn:aws:kms:")
  ])

  s3_buckets = flatten([local.s3_bucket_names, local.s3_bucket_arns])
  context    = jsondecode(jsonencode(module.context.accounts))
  iam_role   = local.context.aws[0].prefix.dot.full.function
}

variable "prefix" {
  type        = string
  description = "(Optional). Prefix override for all generated naming conventions."
  default     = "cs"
}

variable "client" {
  type        = string
  description = "(Optional). Name of the client"
  default     = "ClearScale"
}

variable "project" {
  type        = string
  description = "(Optional). Name of the client project."
  default     = "pmod"
}

variable "account" {
  description = "(Optional). Cloud provider account object."
  type = object({
    key      = optional(string, "current")
    provider = optional(string, "aws")
    id       = optional(string, "*") 
    name     = string
    region   = optional(string, null)
  })
  default = {
    id   = "*"
    name = "shared"
  }
}

variable "env" {
  type        = string
  description = "(Optional). Name of the current environment."
  default     = "dev"
}

variable "region" {
  type        = string
  description = "(Optional). AWS region."
  default     = "us-west-1"
}

variable "name" {
  type        = string
  description = "(Optional). Code name for this deployment. Used to add additional context to dependency resources."
  default     = "codecommit"
}

#
# SCM repository
#
variable "repo" {
  description = "(Required). Name of the code repository. Optionally, create repo."
  type = object({
    name   = string
    create = optional(bool, false)
    tags   = optional(any,  null)

    account = optional(object({
      id   = optional(number, null)
      name = optional(string, null)
    }), null)

    # Only applicable if create == true
    description     = optional(string, "This repository was brought to you by ClearScale.")
    default_branch  = optional(string, "master")
  })
}

#
# For use with CodePipeline or similiar:
# ARNs of trusted roles, S3 bucket ARNs for asset caching, and KMS keys for
# encrypting and decrypting data. Just supply the ARNs as a list of strings
# and the code will do the rest.
#
# Supported to date:
# - ARNs of the IAM service role for CodePipeline
# - ARNs of the KMS key used for encryption or decryption
# - ARNs of S3 buckets to store assets in
#
variable "trusts" {
  description = "(Optional). ARNs of IAM roles, KMS keys, or S3 buckets that this CodeCommit repository should trust or allow."
  type        = list(string)
  default     = []
}