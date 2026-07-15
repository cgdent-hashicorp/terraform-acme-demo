terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.90"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.55"
    }
  }
}

provider "hcp" {}
provider "tfe" {}

# ---------------------------------------------------------------------------
# Projects: one HCP project to hold the Waypoint config, one HCP Terraform
# project to hold the workspaces Waypoint will create on developers' behalf.
# ---------------------------------------------------------------------------

resource "hcp_project" "demo" {
  name        = "waypoint-vpc-demo"
  description = "Self-service VPC template: HCP Waypoint fronting the cgdent-ibm/vpc/aws module"
}

resource "tfe_project" "demo" {
  organization = var.tfc_organization
  name         = "waypoint-vpc-demo"
}

# ---------------------------------------------------------------------------
# Connect this Waypoint project to HCP Terraform. Waypoint uses a team token
# to create workspaces and run plans/applies in tfe_project.demo.
# ---------------------------------------------------------------------------

data "tfe_team" "platform" {
  name         = var.tfc_team_name
  organization = var.tfc_organization
}

resource "tfe_team_token" "waypoint" {
  team_id = data.tfe_team.platform.id
}

resource "hcp_waypoint_tfc_config" "this" {
  project_id   = hcp_project.demo.resource_id
  token        = tfe_team_token.waypoint.token
  tfc_org_name = var.tfc_organization
}

# ---------------------------------------------------------------------------
# AWS credentials for the workspaces Waypoint creates. Project-scoped
# variable set so every workspace created under tfe_project.demo inherits
# them automatically, with no per-workspace wiring.
# ---------------------------------------------------------------------------

resource "tfe_variable_set" "aws_creds" {
  name         = "waypoint-vpc-demo-aws-creds"
  organization = var.tfc_organization
}

resource "tfe_project_variable_set" "aws_creds" {
  variable_set_id = tfe_variable_set.aws_creds.id
  project_id      = tfe_project.demo.id
}

resource "tfe_variable" "aws_access_key" {
  key             = "AWS_ACCESS_KEY_ID"
  value           = var.aws_access_key_id
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.aws_creds.id
}

resource "tfe_variable" "aws_secret_key" {
  key             = "AWS_SECRET_ACCESS_KEY"
  value           = var.aws_secret_access_key
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.aws_creds.id
}

resource "tfe_variable" "aws_region" {
  key             = "AWS_DEFAULT_REGION"
  value           = var.aws_region
  category        = "env"
  variable_set_id = tfe_variable_set.aws_creds.id
}

# ---------------------------------------------------------------------------
# Template: the golden path developers use to stand up a new VPC.
# The vpc module (app.terraform.io/cgdent-ibm/vpc/aws) is already published
# to the private registry, so it's looked up rather than registered from a
# VCS repo, then wrapped as a no-code module and a Waypoint template.
# ---------------------------------------------------------------------------

data "tfe_registry_module" "vpc" {
  organization    = var.tfc_organization
  name            = "vpc"
  module_provider = "aws"
}

resource "tfe_no_code_module" "vpc" {
  organization    = var.tfc_organization
  registry_module = data.tfe_registry_module.vpc.id
  enabled         = true
  # Pinned to the version this template was built against, per
  # module.vpc in aws/main.tf. Required whenever variable_options is set.
  version_pin = "1.0.1"

  variable_options {
    name    = "name"
    type    = "string"
    options = ["dev-vpc", "staging-vpc", "prod-vpc"]
  }

  variable_options {
    name    = "vpc_cidr"
    type    = "string"
    options = ["10.0.0.0/16", "10.1.0.0/16", "10.2.0.0/16"]
  }

  variable_options {
    name    = "public_subnet_cidr"
    type    = "string"
    options = ["10.0.1.0/24", "10.1.1.0/24", "10.2.1.0/24"]
  }
}

resource "hcp_waypoint_template" "vpc" {
  project_id  = hcp_project.demo.resource_id
  name        = "AWS VPC"
  summary     = "Stand up a VPC with a public subnet on AWS in minutes."
  description = "Golden-path template for provisioning a VPC + public subnet on AWS. Backed by the cgdent-ibm/vpc/aws module — same module, state, and policy checks as any other Terraform workspace."
  labels      = ["aws", "networking", "vpc"]

  terraform_project_id            = tfe_project.demo.id
  terraform_no_code_module_id     = tfe_no_code_module.vpc.id
  terraform_no_code_module_source = "app.terraform.io/${var.tfc_organization}/vpc/aws"
  use_module_readme               = true

  depends_on = [hcp_waypoint_tfc_config.this]
}
