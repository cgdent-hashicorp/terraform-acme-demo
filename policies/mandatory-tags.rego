package terraform.tags

required_tags := {"Environment", "Owner", "CostCentre"}

#
# Deny rule
#
deny[msg] {
  rc := input.resource_changes[_]

  # Ignore deletes
  not is_delete(rc)

  # Missing required tags
  missing := required_tags - object.keys(rc.change.after.tags)
  count(missing) > 0

  msg := sprintf(
    "Resource %s is missing required tags: %v",
    [rc.address, missing]
  )
}

#
# Helper: detect deletes safely
#
is_delete(rc) {
  rc.change.after == null
}
