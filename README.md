# Terraform

A collection of Infrastructure as Code labs built with Terraform, each provisioning and validating real infrastructure on Azure. Every lab lives in its own numbered folder with the same internal layout: the Terraform configuration itself, a written lab walkthrough, sanitized screenshots, and a lessons learned writeup covering the real errors hit along the way.

---

## Repo Structure

Each lab folder holds everything for that lab and follows the same layout:

```
0N-lab-name/
├── README.md          # Project overview, objectives, architecture, and status for this lab
├── terraform/          # The actual .tf configuration (main.tf, variables.tf, outputs.tf, .tfvars.example)
├── labs/                # Numbered walkthrough of the build
├── screenshots/         # Sanitized evidence screenshots, indexed by their own README
└── lessons-learned.md  # Real errors hit, how they were fixed, and what to do differently next time
```

Real secrets never get committed: every lab's `.gitignore` excludes `terraform.tfvars` and `.tfstate` files, and each `terraform/` folder ships a `terraform.tfvars.example` with placeholder values meant only for the lab instead.

---

## Labs

| Lab | Description | Status |
| --- | --- | --- |
| [01 — Active Directory Domain Controller](01-active-directory-domain-controller) | Provision, validate, and tear down an Azure AD Domain Controller entirely through Terraform — the Infrastructure as Code counterpart to the manual [active-directory-azure-lab](https://github.com/JamespennIV/active-directory-azure-lab) build. | Complete |

---

## Tools Used

- Terraform (`hashicorp/azurerm` provider)
- Microsoft Azure (Virtual Machines, Networking, Identity)
- Checkov (static analysis / policy scanning)
- Visual Studio Code
- PowerShell

---

## Skills Demonstrated

- Infrastructure as Code: writing, planning, applying, and destroying Terraform configurations from scratch
- Reading and resolving real `plan`/`apply` errors (block naming, undeclared variables, output syntax, resource dependencies)
- Bootstrapping configuration inside the VM (role installs, service promotion) via VM extensions instead of manual steps
- Static analysis / policy scanning of IaC with Checkov
- Validating the provisioned infrastructure after deployment, not just confirming a clean `apply`
- Infrastructure teardown and cost hygiene

---

## Security Note

Every lab's real `terraform.tfvars` and `.tfstate` files are excluded from version control via `.gitignore` — only sanitized `.tfvars.example` templates with placeholder values are committed. Every screenshot in this repo has been reviewed and redacted before upload: public IP addresses, subscription/tenant IDs, and hostnames are blacked out. See each lab's own `README.md` for its specific security notes.

---

## Key Takeaway

This repo is the growing Infrastructure as Code side of my lab portfolio — each entry takes an environment I've also built manually elsewhere and rebuilds it as a repeatable Terraform configuration under version control, real troubleshooting included.
