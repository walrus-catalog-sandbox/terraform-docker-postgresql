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

  architecture                  = "replication"
  replication_readonly_replicas = 3

  resources = {
    cpu    = 2
    memory = 2024
  }

  seeding = {
    type = "text"
    text = {
      content = <<-EOF
--- company table
DROP TABLE IF EXISTS company;
CREATE TABLE company
(
    id      SERIAL PRIMARY KEY,
    name    TEXT NOT NULL,
    age     INT  NOT NULL,
    address CHAR(50),
    salary  REAL
);


-- company data
INSERT INTO company (name, age, address, salary)
VALUES ('Paul', 32, 'California', 20000.00);
INSERT INTO company (name, age, address, salary)
VALUES ('Allen', 25, 'Texas', 15000.00);
INSERT INTO company (name, age, address, salary)
VALUES ('Teddy', 23, 'Norway', 20000.00);
INSERT INTO company (name, age, address, salary)
VALUES ('Mark', 25, 'Rich-Mond ', 65000.00);
INSERT INTO company (name, age, address, salary)
VALUES ('David', 27, 'Texas', 85000.00);
INSERT INTO company (name, age, address, salary)
VALUES ('Kim', 22, 'South-Hall', 45000.00);
INSERT INTO company (name, age, address, salary)
VALUES ('James', 24, 'Houston', 10000.00);
EOF
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
