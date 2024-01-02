# Standalone Example

Deploy PostgreSQL service in standalone architecture by root moudle.

```bash
# setup infra
$ tf apply -auto-approve \
  -target=docker_network.example 

# create service
$ tf apply -auto-approve
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | >= 3.0.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | >= 3.0.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [docker_network.example](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | n/a |
| <a name="output_address_readonly"></a> [address\_readonly](#output\_address\_readonly) | n/a |
| <a name="output_connection"></a> [connection](#output\_connection) | n/a |
| <a name="output_connection_readonly"></a> [connection\_readonly](#output\_connection\_readonly) | n/a |
| <a name="output_context"></a> [context](#output\_context) | n/a |
| <a name="output_database"></a> [database](#output\_database) | n/a |
| <a name="output_password"></a> [password](#output\_password) | n/a |
| <a name="output_port"></a> [port](#output\_port) | n/a |
| <a name="output_refer"></a> [refer](#output\_refer) | n/a |
| <a name="output_username"></a> [username](#output\_username) | n/a |
<!-- END_TF_DOCS -->
