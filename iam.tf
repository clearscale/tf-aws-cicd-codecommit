#
# Parse trusted ARNs and configure the permissions
#
#
resource "aws_iam_role" "trusts" {
  count = length(local.iam_roles) > 0 ? 1 : 1
  name  = local.iam_role

  assume_role_policy = length(local.org_ids) > 0 ? jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          AWS = (length(local.iam_roles) > 0
            ? [for arn in local.iam_roles
            : arn if arn != null] : ["*"]
          ),
          Service = [
            "codepipeline.amazonaws.com",
            "codebuild.amazonaws.com",
            "codecommit.amazonaws.com"
          ]
        },
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = local.org_ids
          }
        }
      }
    ]
  }) : jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          AWS = (length(local.iam_roles) > 0
            ? [for arn in local.iam_roles
            : arn if arn != null] : ["*"]
          ),
          Service = [
            "codepipeline.amazonaws.com",
            "codebuild.amazonaws.com",
            "codecommit.amazonaws.com"
          ]
        }
      }
    ]
  })
}


resource "aws_iam_policy" "trusts" {
  count       = (length(local.s3_buckets) > 0 || length(local.kms_keys) > 0 || length(local.org_ids) > 0) ? 1 : 0
  name        = local.iam_role
  description = "Default '${var.repo.name}' CodeCommit policy for the '${local.project}' project."
  path        = "/"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = flatten([[
      {
        Action = [
          "codecommit:GitPull",
          "codecommit:Get*",
          "codecommit:List*",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive",
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:codecommit:${var.region}:${local.account_id_repo}:${var.repo.name}"
        ]
      }],(length(local.s3_buckets) > 0 ? [{
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:GetLifecycleConfiguration",
          "s3:GetBucketOwnershipControls",
          "s3:GetBucketPolicy",
          "s3:GetObjectVersion",
          "s3:ListMultipartUploadParts",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        Effect   = "Allow",
        Resource = flatten([for bucket in local.s3_buckets : [
          bucket,
          "${bucket}/*"
        ]])
      }] : []),(length(local.kms_keys) > 0 ? [{
        Action = [
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:Decrypt"
        ],
        Effect   = "Allow",
        Resource = local.kms_keys
      }] : [])
    ])
  })

  lifecycle {
    ignore_changes = [
      tags, tags_all
    ]
  }
}

resource "aws_iam_role_policy_attachment" "trusts" {
  count      = (length(local.s3_buckets) > 0 || length(local.kms_keys) > 0) ? 1 : 0
  policy_arn = aws_iam_policy.trusts[0].arn
  role       = aws_iam_role.trusts[0].id
}
