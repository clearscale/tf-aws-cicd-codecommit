output "role" {
  description = "The service role assigned to the CodeCommit repository."
  value  = (length(var.trusts) > 0 ? {
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

output "iam_role" {
  description = "The name of the IAM role created for the repository."
  value       = local.iam_role
}