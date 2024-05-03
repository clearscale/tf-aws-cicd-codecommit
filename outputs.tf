output "name" {
  description = "This CodeCommit repository name."
  value       = var.repo.name
}

output "role" {
  description = "The service role assigned to the CodeCommit repository."
  value  = (length(aws_iam_role.trusts) > 0 ? {
    arn          = aws_iam_role.trusts[0].arn
    created_date = aws_iam_role.trusts[0].create_date
    id           = aws_iam_role.trusts[0].id
    name         = aws_iam_role.trusts[0].name
    unique_id    = aws_iam_role.trusts[0].unique_id
    trusts = {
      accounts     = local.ext_accounts
      iam_roles    = local.iam_roles
      s3_buckets   = local.s3_buckets
      kms_keys     = local.kms_keys
    }
  } : null)
}

output "org_ids" {
  description = "The Organization IDs that were passed as trusts."
  value       = local.org_ids
}