locals {
  hosts = [
    format("%s.%s.svc.%s", local.master_name, local.namespace, local.domain_suffix)
  ]
  hosts_readonly = local.architecture == "replication" ? [
    for i in range(0, var.replication_readonly_replicas) : format("%s-slave-%d.%s.svc.%s", local.resource_name, i, local.namespace, local.domain_suffix)
  ] : []

  endpoints = flatten([
    for c in local.hosts : formatlist("%s:5432", c)
  ])
  endpoints_readonly = [
    for c in(local.hosts_readonly != null ? local.hosts_readonly : []) : format("%s:5432", c)
  ]
}

#
# Orchestration
#

output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "refer" {
  description = "The refer, a map, including hosts, ports and account, which is used for dependencies or collaborations."
  sensitive   = true
  value = {
    schema = "docker:postgresql"
    params = {
      selector           = local.labels
      hosts              = local.hosts
      hosts_readonly     = local.hosts_readonly
      ports              = [5432]
      endpoints          = local.endpoints
      endpoints_readonly = local.endpoints_readonly
      database           = local.database
      username           = local.username
      password           = nonsensitive(local.password)
    }
  }
}

#
# Reference
#

output "connection" {
  description = "The connection, a string combined host and port, might be a comma separated string or a single string."
  value       = join(",", local.endpoints)
}

output "connection_readonly" {
  description = "The readonly connection, a string combined host and port, might be a comma separated string or a single string."
  value       = join(",", local.endpoints_readonly)
}

output "address" {
  description = "The address, a string only has host, might be a comma separated string or a single string."
  value       = join(",", local.hosts)
}

output "address_readonly" {
  description = "The readonly address, a string only has host, might be a comma separated string or a single string."
  value       = join(",", local.hosts_readonly)
}

output "port" {
  description = "The port of the PostgreSQL service."
  value       = 5432
}

output "database" {
  description = "The name of PostgreSQL database to access."
  value       = local.database
}

output "username" {
  description = "The username of the account to access the database."
  value       = local.username
}

output "password" {
  value       = local.password
  description = "The password of the account to access the database."
  sensitive   = true
}
