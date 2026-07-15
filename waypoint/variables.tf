variable "tfc_organization" {
  type        = string
  description = "HCP Terraform organization name. Must be the same org that owns app.terraform.io/<org>/vpc/aws in the private registry — no-code modules can only wrap a registry module in their own org."
  default     = "cgdent-ibm"
}

variable "tfc_team_name" {
  type        = string
  description = "HCP Terraform team whose token Waypoint will use to create and run workspaces. Needs 'Manage Workspaces' and 'Manage Projects' permissions."
  default     = "owners"
}

variable "aws_region" {
  type        = string
  description = "AWS region the demo VPC deploys into."
  default     = "us-east-1"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key used by the workspaces Waypoint creates on developers' behalf. Demo-only shortcut — use HCP Terraform's dynamic provider credentials (OIDC) for anything beyond a demo."
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret key used by the workspaces Waypoint creates on developers' behalf."
  sensitive   = true
}
