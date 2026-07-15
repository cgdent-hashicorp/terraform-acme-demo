output "hcp_project_id" {
  description = "HCP project the Waypoint config lives in."
  value       = hcp_project.demo.resource_id
}

output "tfc_project_id" {
  description = "HCP Terraform project holding the workspaces Waypoint creates."
  value       = tfe_project.demo.id
}

output "waypoint_template_id" {
  description = "ID of the 'AWS VPC' template — pass to `hcp waypoint application create` if scripting instead of clicking."
  value       = hcp_waypoint_template.vpc.id
}

output "waypoint_portal_url" {
  description = "Jump straight to HCP Waypoint."
  value       = "https://portal.cloud.hashicorp.com/waypoint"
}
