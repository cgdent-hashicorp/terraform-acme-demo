# ACME Terraform Cloud Demo

This repository contains a demo-ready Terraform codebase and helper scripts to showcase
Terraform Cloud (TFC) workflows, private module registry usage, policies (Sentinel),
and GitHub Actions automation for ACME Corp's Cloud 2.0 demo.

## Repo structure

- `modules/aws-webapp/` - reusable VPC + webapp module
- `aws/` - example AWS environment consuming the module
- `azure/` - Azure example (resource group)
- `waypoint/` - HCP Waypoint template wrapping `app.terraform.io/cgdent-ibm/vpc/aws` as a self-service golden path
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

## HCP Waypoint template
`waypoint/` stands up an HCP Waypoint self-service template ("AWS VPC") backed by the
already-published `app.terraform.io/cgdent-ibm/vpc/aws` module (v1.0.1). Developers get a
one-click golden path to a VPC + public subnet instead of writing HCL by hand.

```bash
cd waypoint
cp terraform.tfvars.example terraform.tfvars   # fill in tfc_organization, etc.
export TF_VAR_aws_access_key_id=...
export TF_VAR_aws_secret_access_key=...
terraform init && terraform apply
```

`tfc_organization` must be the org that owns the `vpc` module in the private registry
(`cgdent-ibm`) — a no-code module can only wrap a registry module in its own org. After
apply, the template shows up in the HCP Waypoint portal (URL in the `waypoint_portal_url`
output).
