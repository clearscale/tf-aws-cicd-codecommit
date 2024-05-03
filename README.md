# Terraform AWS/CICD CodeCommit

This module efficiently creates and manages AWS `CodeCommit` repositories. Although manually creating and managing Git repositories is often considered best practice, this module offers the capability for automated management. It's particularly useful for configuring necessary IAM roles and resources, essential when integrating CodeCommit repositories with other AWS services like `CodeBuild` and `CodePipeline`.

Additionally, when managing repositories in a multi-account setup, it's advisable to place the repositories in a `shared` account. This approach facilitates cross-account permissions by allowing IAM roles from different accounts to be incorporated into `var.trusts`. This strategy streamlines repository access and management across various accounts.

## Usage

Include the module in your Terraformcode

```terraform
module "codecommit" {
  source = "github.com/clearscale/tf-aws-cicd-codecommit.git?ref=v1.0.0"

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
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_std"></a> [std](#module\_std) | github.com/clearscale/tf-standards.git | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_codecommit_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository) | resource |
| [aws_iam_policy.trusts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.trusts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.trusts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account"></a> [account](#input\_account) | (Optional). Cloud provider account object. | <pre>object({<br>    key      = optional(string, "current")<br>    provider = optional(string, "aws")<br>    id       = optional(string, "*") <br>    name     = string<br>    region   = optional(string, null)<br>  })</pre> | <pre>{<br>  "id": "*",<br>  "name": "shared"<br>}</pre> | no |
| <a name="input_client"></a> [client](#input\_client) | (Optional). Name of the client | `string` | `"ClearScale"` | no |
| <a name="input_env"></a> [env](#input\_env) | (Optional). Name of the current environment. | `string` | `"dev"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional). Code name for this deployment. Used to add additional context to dependency resources like IAM roles. Repository name should be added to var.repo.name. | `string` | `"codecommit"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Optional). Prefix override for all generated naming conventions. | `string` | `"cs"` | no |
| <a name="input_project"></a> [project](#input\_project) | (Optional). Name of the client project. | `string` | `"pmod"` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional). AWS region. | `string` | `"us-west-1"` | no |
| <a name="input_repo"></a> [repo](#input\_repo) | (Required). Name of the code repository. Optionally, create repo. | <pre>object({<br>    name   = string<br>    create = optional(bool, false)<br>    tags   = optional(any,  null)<br><br>    account = optional(object({<br>      id   = optional(number, null)<br>      name = optional(string, null)<br>    }), null)<br><br>    # Only applicable if create == true<br>    description     = optional(string, "This repository was brought to you by ClearScale.")<br>    default_branch  = optional(string, "main")<br>  })</pre> | n/a | yes |
| <a name="input_trusts"></a> [trusts](#input\_trusts) | (Optional). ARNs of IAM roles, KMS keys, or S3 buckets that this CodeCommit repository should trust or allow. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | This CodeCommit repository name. |
| <a name="output_org_ids"></a> [org\_ids](#output\_org\_ids) | The Organization IDs that were passed as trusts. |
| <a name="output_role"></a> [role](#output\_role) | The service role assigned to the CodeCommit repository. |
<!-- END_TF_DOCS -->