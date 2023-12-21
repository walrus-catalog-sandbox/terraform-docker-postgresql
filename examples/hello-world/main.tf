terraform {
  required_version = ">= 1.0"
}

module "this" {
  source = "../.."

  context = {
    project = {
      "name" = "project_name"
      "id"   = "project_id"
    }
    environment = {
      "name" = "environment_name"
      "id"   = "environment_id"
    }
    resource = {
      "name" = "resource_name"
      "id"   = "resource_id"
    }
  }
}

output "project_name" {
  value = module.this.walrus_project_name
}

output "environment_name" {
  value = module.this.walrus_environment_name
}

output "resource_name" {
  value = module.this.walrus_resource_name
}
