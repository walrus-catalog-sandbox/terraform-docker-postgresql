# Development

The Makefile includes some useful commands for development. You can build locally using the make command. You can run `make help` for details. The output is shown as below.

```bash
$ make help
#
# Usage:
#
#   * [dev] `make generate`, generate docs.
#
#   * [dev] `make lint`, check style and security.
#           - `LINT_DIRTY=true make lint` verify whether the code tree is dirty.
#
#   * [dev] `make test`, execute unit testing.
#
#   * [ci]  `make ci`, execute `make generate`, `make lint` and `make test`.
#

```
