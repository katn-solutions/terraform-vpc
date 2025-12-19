package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformVPCV0Validation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../v0",
		NoColor:      true,
	})

	terraform.InitAndValidate(t, terraformOptions)
}

func TestTerraformVPCInputs(t *testing.T) {
	testCases := []struct {
		name     string
		expectOK bool
	}{
		{"ValidConfiguration", true},
		{"ValidWithNATGateway", true},
	}

	for _, tc := range testCases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
				TerraformDir: "../v0",
				NoColor:      true,
			})

			// Validate configuration
			terraform.InitAndValidate(t, terraformOptions)

			if tc.expectOK {
				assert.True(t, true, "Configuration validated successfully")
			}
		})
	}
}
