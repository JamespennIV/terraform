# Lab 01: Active Directory Domain Controller

## Project Overview

This lab builds an Azure Active Directory Domain Controller entirely through Terraform — from a bare Azure subscription to a validated, running domain controller — instead of provisioning it manually through the Azure Portal and Server Manager (see the companion [active-directory-azure-lab](https://github.com/JamespennIV/active-directory-azure-lab) for that manual build).

The infrastructure, the AD DS installation, and the forest promotion are all defined as code, deployed with `terraform apply`, validated over RDP, and torn down with `terraform destroy` — a fully repeatable path, kept under version control, to the same domain controller outcome.

---

## Business Scenario

Standing up identity infrastructure by hand doesn't scale and isn't easily repeatable, auditable, or reviewable before it touches production. This lab builds the same kind of domain controller a small organization would need, but through Infrastructure as Code, so the environment can be:

- Deployed identically to multiple environments (dev/test/lab) from the same configuration
- Reviewed and kept under version control before anything is provisioned
- Torn down and rebuilt on demand without manual reconfiguration
- Documented by the code itself, not just by screenshots from a single manual pass through the portal

---

## Lab Objectives

- Write a Terraform configuration provisioning a resource group, network, public IP, NSG, NIC, and Windows Server VM
- Bootstrap the AD DS role installation and forest promotion through a VM extension, entirely from `terraform apply`
- Troubleshoot real Terraform syntax and configuration errors using `plan` output
- Validate the deployed domain controller over RDP with PowerShell verification commands
- Run static analysis (Checkov) against the configuration and review its findings
- Tear down the environment cleanly with `terraform destroy`

---

## Tools Used

- Microsoft Azure (Virtual Machines, Networking)
- Terraform (`hashicorp/azurerm` provider)
- Windows Server 2022 Datacenter
- Active Directory Domain Services (AD DS)
- Checkov (static analysis / policy scanning)
- Visual Studio Code
- PowerShell

---

## Skills Demonstrated

- Infrastructure as Code with Terraform (`init`, `plan`, `apply`, `destroy`)
- Azure resource provisioning: resource groups, virtual networks, subnets, NSGs, NICs, public IPs, VMs
- Bootstrapping application/service installation via VM extensions (`CustomScriptExtension`)
- Reading and resolving real Terraform plan/apply errors (block naming, undeclared variables, output syntax)
- Use of `terraform taint` to force clean recreation of a misconfigured resource
- Static analysis / policy scanning of IaC with Checkov
- Validation of Active Directory services via PowerShell after deployment
- Infrastructure teardown and cost hygiene (`terraform destroy`)

---

## Lab Architecture

```
azurerm_resource_group.main (rg-ad-james)
│
├── azurerm_virtual_network.main
│   └── azurerm_subnet.main
│
├── azurerm_public_ip.main
├── azurerm_network_security_group.main
│   └── security_rule: Allow-RDP (3389, inbound)
│
├── azurerm_network_interface.main
│   └── azurerm_network_interface_security_group_association.main
│
├── azurerm_windows_virtual_machine.main (vm-ad-james, Standard_D2alds_v7, Spot instance)
│
└── azurerm_virtual_machine_extension.main (install-ad-ds)
    └── CustomScriptExtension → Install-ADDSForest (corp.james.com / CORP)
```

---

## Lab Status

- [x] Terraform configuration written (`main.tf`, `variables.tf`, `outputs.tf`)
- [x] `terraform plan` reaching a clean 9-resource plan
- [x] `terraform apply` completed successfully
- [x] Domain controller validated over RDP (NTDS service, `Get-ADDomain`, `Get-ADDomainController`, DNS resolution)
- [x] Checkov static analysis run and findings reviewed
- [x] `terraform destroy` run and confirmed
- [x] Documentation screenshots sanitized and embedded (see `screenshots/lab-01-terraform-ad-domain-controller/`)

---

## Security Note

`terraform.tfvars` (with real passwords) and all `.tfstate` files are excluded via `.gitignore` and must never be committed. Use [`terraform/terraform.tfvars.example`](terraform/terraform.tfvars.example) as a template — the passwords shown there are lab-only placeholder values, not real credentials. Any screenshots added to this folder should have public IP addresses, subscription/tenant IDs, and hostnames redacted before upload, matching the convention used across this portfolio's other lab repos.

---

## Key Takeaway

This lab demonstrates the same Active Directory domain controller outcome as the manual build done through the Azure Portal in [active-directory-azure-lab](https://github.com/JamespennIV/active-directory-azure-lab), but through Infrastructure as Code — including the real troubleshooting that comes with writing and debugging Terraform from scratch, not just a deployment that went smoothly on the first try. It's the repeatable counterpart, kept under version control, to the manual portal build, showing both approaches to the same problem.

---

## Video Walkthrough

[Watch the full build on Loom](https://loom.com/share/92a1f59614f049bf94e8c806d60293bb)
