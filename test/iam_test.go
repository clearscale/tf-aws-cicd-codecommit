package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

/**
 * Using default variables
 * TODO: Test the rest of the values
 */
func TestTerraformIAMRole(t *testing.T) {
	// Define the repo structure
	repo := map[string]string{
		"name": "example-hello-world",
	}

	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"repo": repo,
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	output := terraform.Output(t, terraformOptions, "iam_role")

	// Dash notation
	expectedRoleName := "CsPmod.Shared.Uswest1.Dev.CodeCommit.Examplehelloworld"
	assert.Equal(t, expectedRoleName, output)
}
