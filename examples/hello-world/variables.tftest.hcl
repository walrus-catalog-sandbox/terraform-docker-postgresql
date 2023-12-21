run "valid_variable" {
  command = plan

  assert {
    condition     = module.this.walrus_project_name == "project_name"
    error_message = "Unexpected output project name"
  }

  assert {
    condition     = module.this.walrus_resource_name == "resource_name"
    error_message = "Unexpected output resource name"
  }
}
