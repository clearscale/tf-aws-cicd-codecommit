# Terraform AWS/CICD CodeCommit

This module efficiently creates and manages AWS `CodeCommit` repositories. Although manually creating and managing Git repositories is often considered best practice, this module offers the capability for automated management. It's particularly useful for configuring necessary IAM roles and resources, essential when integrating CodeCommit repositories with other AWS services like `CodeBuild` and `CodePipeline`.

Additionally, when managing repositories in a multi-account setup, it's advisable to place the repositories in a `shared` account. This approach facilitates cross-account permissions by allowing IAM roles from different accounts to be incorporated into `var.trusts`. This strategy streamlines repository access and management across various accounts.

## Usage

Include the module in your Terraformcode

```terraform
module "codecommit" {
  source    = "https://github.com/clearscale/tf-aws-cicd-codecommit.git"

  accounts = [
    { name = "shared", provider = "aws", key = "shared"}
  ]

  prefix   = "ex"
  client   = "example"
  project  = "aws"
  env      = "dev"
  region   = "us-east-1"
  name     = "codecommit"
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