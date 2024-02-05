# Docker PostgreSQL Service

Terraform module which deploys PostgreSQL service on Docker. Powered by [Bitnami PostgreSQL Docker Image](https://hub.docker.com/r/bitnami/postgresql).

- [x] Support standalone(one read-write instance) and replication(one read-write instance and multiple read-only instances, for read write splitting) architecture.
- [x] Support seeding database at first-time creating.

## Usage

```hcl
module "example" {
  source = "..."

  infrastructure = {
    network_id = "..."
  }

  architecture = "replication"

  engine_version = "15.0"
}
```

## Examples

- [Standalone](./examples/standalone)
- [Replication](./examples/replication)

## Contributing

Please read our [contributing guide](./docs/CONTRIBUTING.md) if you're interested in contributing to Walrus template.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | >= 3.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | >= 3.0.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_master"></a> [master](#module\_master) | github.com/walrus-catalog/terraform-docker-containerservice | v0.2.1&depth=1 |
| <a name="module_slave"></a> [slave](#module\_slave) | github.com/walrus-catalog/terraform-docker-containerservice | v0.2.1&depth=1 |

## Resources

| Name | Type |
|------|------|
| [docker_network.network](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/data-sources/network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Specify the deployment architecture, select from standalone or replication. | `string` | `"standalone"` | no |
| <a name="input_context"></a> [context](#input\_context) | Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.<br><br>Examples:<pre>context:<br>  project:<br>    name: string<br>    id: string<br>  environment:<br>    name: string<br>    id: string<br>  resource:<br>    name: string<br>    id: string</pre> | `map(any)` | `{}` | no |
| <a name="input_database"></a> [database](#input\_database) | Specify the database name. The database name must be 2-64 characters long and start with any lower letter, combined with number, or symbols: - \_.<br>The database name cannot be PostgreSQL forbidden keyword. | `string` | `"mydb"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Specify the deployment engine version, select from https://hub.docker.com/r/bitnami/postgresql/tags. | `string` | `"16.0"` | no |
| <a name="input_infrastructure"></a> [infrastructure](#input\_infrastructure) | Specify the infrastructure information for deploying.<br><br>Examples:<pre>infrastructure:<br>  network_id: string, optional<br>  domain_suffix: string, optional</pre> | <pre>object({<br>    network_id    = optional(string, "local-walrus")<br>    domain_suffix = optional(string, "cluster.local")<br>  })</pre> | <pre>{<br>  "domain_suffix": "cluster.local",<br>  "network_id": "local-walrus"<br>}</pre> | no |
| <a name="input_password"></a> [password](#input\_password) | Specify the account password. The password must be 8-32 characters long and start with any letter, number, or symbols: ! # $ % ^ & * ( ) \_ + - =.<br>If not specified, it will use the first 16 characters of the username md5 hash value. | `string` | `null` | no |
| <a name="input_replication_readonly_replicas"></a> [replication\_readonly\_replicas](#input\_replication\_readonly\_replicas) | Specify the number of read-only replicas under the replication deployment. | `number` | `1` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Specify the computing resources.<br><br>Examples:<pre>resources:<br>  cpu: number, optional<br>  memory: number, optional       # in megabyte</pre> | <pre>object({<br>    cpu    = optional(number, 0.25)<br>    memory = optional(number, 1024)<br>  })</pre> | <pre>{<br>  "cpu": 0.25,<br>  "memory": 1024<br>}</pre> | no |
| <a name="input_seeding"></a> [seeding](#input\_seeding) | Specify the configuration to seed the database at first-time creating.<br><br>Seeding increases the startup time waiting and also needs proper permission, <br>like root account.<br><br>Examples:<pre>seeding:<br>  type: none/url/text<br>  url:                           <br>    location: string<br>  text:                          <br>    content: string</pre> | <pre>object({<br>    type = optional(string, "none")<br>    url = optional(object({<br>      location = string<br>    }))<br>    text = optional(object({<br>      content = string<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Specify the account username. The username must be 2-16 characters long and start with lower letter, combined with number, or symbol: \_.<br>The username cannot be PostgreSQL forbidden keyword and root.<br>See https://www.alibabacloud.com/help/en/rds/developer-reference/api-rds-2014-08-15-createaccount. | `string` | `"rdsuser"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | The address, a string only has host, might be a comma separated string or a single string. |
| <a name="output_address_readonly"></a> [address\_readonly](#output\_address\_readonly) | The readonly address, a string only has host, might be a comma separated string or a single string. |
| <a name="output_connection"></a> [connection](#output\_connection) | The connection, a string combined host and port, might be a comma separated string or a single string. |
| <a name="output_connection_readonly"></a> [connection\_readonly](#output\_connection\_readonly) | The readonly connection, a string combined host and port, might be a comma separated string or a single string. |
| <a name="output_context"></a> [context](#output\_context) | The input context, a map, which is used for orchestration. |
| <a name="output_database"></a> [database](#output\_database) | The name of PostgreSQL database to access. |
| <a name="output_password"></a> [password](#output\_password) | The password of the account to access the database. |
| <a name="output_port"></a> [port](#output\_port) | The port of the PostgreSQL service. |
| <a name="output_refer"></a> [refer](#output\_refer) | The refer, a map, including hosts, ports and account, which is used for dependencies or collaborations. |
| <a name="output_username"></a> [username](#output\_username) | The username of the account to access the database. |
<!-- END_TF_DOCS -->

## License

Copyright (c) 2023 [Seal, Inc.](https://seal.io)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [LICENSE](./LICENSE) file for details.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
