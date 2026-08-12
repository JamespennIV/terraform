# Lessons Learned — Terraform Active Directory Lab

---

## What went well

- Writing the configuration by hand instead of generating it made the resource dependency chain (resource group → network → NIC → VM → extension) genuinely clear, rather than something pasted in and only half understood.
- Running `terraform plan` after every fix caught each error immediately instead of letting several stack up before the next `apply`.
- Using a `azurerm_virtual_machine_extension` with a `CustomScriptExtension` to install AD DS and promote the forest meant the entire domain controller build was reproducible from `terraform apply` alone — no manual RDP session required to get the domain running.
- Checkov static analysis ran cleanly against the finished configuration, with only the two expected findings (VM extension use, NIC public IP) reviewed and accepted rather than treated as blockers.

---

## What was challenging

- A one character typo, `security rule` instead of `security_rule`, inside the network security group resource produced a confusing "unexpected block" error until the block name itself was checked against the provider docs rather than the surrounding syntax.
- `terraform.tfvars` set a key named `domain_netbios` instead of `domain_netbios_name`, which is what `variables.tf` actually declares. Terraform doesn't fail on a mismatch like this — it just prints an "undeclared variable" warning for `domain_netbios` and quietly falls back to `domain_netbios_name`'s own default (`"CORP"`). The deployment still came out correct, but only because the default happened to match the intended value — the tfvars override itself was never actually applied. Caught by reading the plan output carefully rather than by anything failing.
- `dsrm_password` is declared as a variable and set in `terraform.tfvars`, but it's never referenced anywhere in `main.tf`. The AD DS install command's `-SafeModeAdministratorPassword` parameter reuses `var.admin_password` instead. Not something that breaks the deployment, but a real gap between what the config declares and what it actually uses — see Next Steps.
- Getting the `commandToExecute` string right inside `jsonencode()` for the VM extension required careful attention to escaping and quoting; a malformed version of it needed `terraform taint` to force Terraform to recreate the extension cleanly instead of leaving one only half applied in place.
- The VM uses an `additional_unattend_content` block to log in automatically as `adadmin` via the Windows unattend answer file, with the admin password embedded in plaintext. That's a fine shortcut for a disposable lab VM but is worth flagging explicitly as something that would never belong in a real deployment — it leaves the password recoverable from the VM's local unattend.xml.

---

## What I'd do differently next time

- Cross-check every variable name in `terraform.tfvars` character-for-character against `variables.tf` before the first `terraform plan` — the `domain_netbios` vs `domain_netbios_name` mismatch would have been caught in seconds this way instead of needing the plan output to surface it.
- Write the VM extension's `commandToExecute` string in a plain text editor first to get the quoting and escaping right, then paste it into the Terraform block, instead of writing it directly inside `jsonencode()`.
- Run `terraform validate` earlier in the process, before `plan`, to catch structural errors in block naming like the `security_rule` typo faster.
- Keep the Checkov scan running continuously during development instead of just at the end, so findings relevant to security surface at the point they're introduced.

---

## Next steps for this lab environment

- Wire `var.dsrm_password` into the AD DS install command's `-SafeModeAdministratorPassword` parameter instead of reusing `var.admin_password`, so the two credentials are actually independent as intended.
- Remove or clearly gate the `additional_unattend_content` AutoLogon block behind a "lab only" variable, so it can't accidentally end up in a deployment that isn't meant to be disposable.
- Parameterize the VM size and region as validated lookup variables instead of plain text strings.
- Add a `terraform fmt` and `terraform validate` pre-commit hook to catch formatting and structural issues before they reach `plan`.
- Extend the configuration to also provision the OU/group/user structure from the manual [Active Directory on Azure Lab](https://github.com/JamespennIV/active-directory-azure-lab) through a remote-exec provisioner or a later PowerShell DSC configuration, so the full identity build — not just the domain promotion — is captured in code.
