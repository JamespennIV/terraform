# Screenshots — Lab 01: Deploy and Validate an Azure Active Directory Domain Controller with Terraform

Sanitized evidence screenshots for [Lab 01](../../labs/Lab_01_AD/README.md), pulled from the Loom walkthrough recording of the build. Filenames are numbered to match the order they appear in the [Steps Performed](../../labs/Lab_01_AD/README.md#steps-performed) list in the lab file.

| # | Step (from Steps Performed) | Filename |
| --- | --- | --- |
| 1 | Confirmed Terraform and working directory setup | `01-vscode-project-setup.png` |
| 2 | Confirmed Terraform and working directory setup (empty `.tf` files scaffolded) | `02-empty-tf-files-scaffolded.png` |
| 3 | Built the Terraform configuration in `main.tf` (NSG `security_rule` typo error) | `05-nsg-security-rule-typo-error.png` |
| 4 | Defined variables in `variables.tf` | `03-variables-tf-in-progress.png` |
| 5 | Defined outputs in `outputs.tf` (missing `value` attribute error) | `04-outputs-tf-missing-value-error.png` |
| 6 | Validated with `terraform plan` (9 to add, undeclared variable warning) | `06-terraform-plan-undeclared-variable-warning.png` |
| 7 | Deployed with `terraform apply` (extension apply complete) | `07-vm-extension-apply-complete.png` |
| 8 | Deployed with `terraform apply` (`terraform.tfvars` and final `terraform output`) | `08-terraform-tfvars-and-final-outputs.png` |

Active Directory verification over RDP (Step 7 in the lab writeup) and `terraform destroy` teardown (Step 8) were not captured on screen during the recording, so there are no screenshots for those steps.

## Sanitization applied

Every screenshot was reviewed and edited before upload. The following were redacted (blacked out) wherever they appeared:

- The Loom recording's webcam overlay (bottom-left corner of every frame)
- The VM's real Azure public IP address (`terraform apply` outputs and `terraform output public_ip` results)
- The real Azure subscription ID (visible in the VM extension's resource ID after `apply` completed)

Nothing else was altered — code, terminal output, error messages, and timestamps are otherwise shown as captured. The admin and DSRM passwords visible in `terraform.tfvars` (`YourAdminPassword123!` / `YourDSRMPassword123!`) are placeholder values used only for the lab, not real credentials; see the [Security Note](../../README.md#security-note) in the repo README for the full policy.
