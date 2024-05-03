# Terraform AWS/CICD CodeCommit

This module efficiently creates and manages AWS `CodeCommit` repositories. Although manually creating and managing Git repositories is often considered best practice, this module offers the capability for automated management. It's particularly useful for configuring necessary IAM roles and resources, essential when integrating CodeCommit repositories with other AWS services like `CodeBuild` and `CodePipeline`.

Additionally, when managing repositories in a multi-account setup, it's advisable to place the repositories in a `shared` account. This approach facilitates cross-account permissions by allowing IAM roles from different accounts to be incorporated into `var.trusts`. This strategy streamlines repository access and management across various accounts.

## Usage

Include the module in your Terraformcode

```terraform
module "codecommit" {
  source    = "github.com/clearscale/tf-aws-cicd-codecommit.git?ref=v1.0.0"

  account = {
    id = "*", name = local.account.name, provider = "aws", key = "current", region = local.region.name
  }


  prefix  = local.context.prefix
  client  = local.context.client
  project = local.context.project
  env     = local.account.name
  region  = local.region.name
  name    = "codecommit"

  repo = {
    name   = "test"
    create = true
  }

  #
  # To be filled in and redeployed after the first successful deployment of the tf-aws-cicd module. These resources do not exist prior to it being deployed.
  # trusts = [
  #  "ARN_CODEPIPELINE_S3_BUCKET,
  #  "ARN_CODEPIPELINE_KMS_KEY", # Must be the key ARN - not an alias.
  #  "ARN_CODEPIPELINE"
  # ]
  #
}
```

## Plan

```bash
terraform plan -var='repo={ name = "example-hello-world"}' -var='trusts=["mys3bucket", "arn-of-iam-role", "arn-of-kms-key"]'
```

## Apply

```bash
terraform apply -var='repo={ name = "example-hello-world"}' -var='trusts=["mys3bucket", "arn-of-iam-role", "arn-of-kms-key"]'
```

## Destroy

```bash
terraform destroy -var='repo={ name = "example-hello-world"}' -var='trusts=["mys3bucket", "arn-of-iam-role", "arn-of-kms-key"]'
```