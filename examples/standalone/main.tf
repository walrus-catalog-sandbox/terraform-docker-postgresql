terraform {
  required_version = ">= 1.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.2"
    }
  }
}

resource "docker_network" "example" {
  name = format("example-%s", replace(uuid(), "-", ""))

  attachable      = true
  check_duplicate = true
  driver          = "bridge"
  options = {
    "com.docker.network.bridge.enable_icc"           = "true"
    "com.docker.network.bridge.enable_ip_masquerade" = "true"
    "com.docker.network.bridge.host_binding_ipv4"    = "0.0.0.0"
    "com.docker.network.driver.mtu"                  = "65535"
  }
}

module "this" {
  source = "../.."

  infrastructure = {
    network_id = docker_network.example.id
  }

  resources = {
    cpu    = 2
    memory = 2024
  }

  seeding = {
    type = "url"
    url = {
      location = "https://raw.githubusercontent.com/seal-io/terraform-provider-byteset/main/byteset/testdata/postgres-lg.sql"
    }
  }
}

output "context" {
  value = module.this.context
}

output "refer" {
  value = nonsensitive(module.this.refer)
}

output "connection" {
  value = module.this.connection
}

output "connection_readonly" {
  value = module.this.connection_readonly
}

output "address" {
  value = module.this.address
}

output "address_readonly" {
  value = module.this.address_readonly
}

output "port" {
  value = module.this.port
}

output "database" {
  value = module.this.database
}

output "username" {
  value = module.this.username
}

output "password" {
  value = nonsensitive(module.this.password)
}
