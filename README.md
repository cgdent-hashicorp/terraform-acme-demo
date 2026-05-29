# ACME Terraform Cloud Demo

This repository contains a demo-ready Terraform codebase and helper scripts to showcase
Terraform Cloud (TFC) workflows, private module registry usage, policies (Sentinel),
and GitHub Actions automation for ACME Corp's Cloud 2.0 demo.

## Repo structure

- `modules/aws-webapp/` - reusable VPC + webapp module
- `aws/` - example AWS environment consuming the module
- `azure/` - Azure example (resource group)
- `policies/` - Sentinel and OPA policies
- `.github/workflows/` - GitHub Actions
- `scripts/` - helper scripts (TFC bootstrap)

## Quick start
1. Push this repo to GitHub: `https://github.com/cgdent-demo/terraform-cloud-demo`
2. Configure Terraform Cloud VCS connection to org `acme-corp`
3. Run:
   ```bash
   bash scripts/bootstrap_tfc.sh
   ```

## Publish module to registry
```bash
git tag v1.0.0 && git push origin v1.0.0
```
