#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Schema helpers. These functions need the
# following variables:
#
#      WARUS_CLI_VERSION  -  The walrus cli version, default is latest.

walrus_cli_version=${WARUS_CLI_VERSION:-"latest"}

function seal::walrus_cli::install() {
  local os
  os=$(seal::util::get_os)
  local arch
  arch=$(seal::util::get_arch)

  curl --retry 3 --retry-all-errors --retry-delay 3 \
    -o "${ROOT_DIR}/.sbin/walrus-cli" \
    -sSfL "https://walrus-cli-1303613262.cos.ap-guangzhou.myqcloud.com/releases/latest/walrus-cli-${os}-${arch}"

  chmod a+x "${ROOT_DIR}/.sbin/walrus-cli"
}

function seal::walrus_cli::validate() {
  local os
  os=$(seal::util::get_os)
  local arch
  arch=$(seal::util::get_arch)

  # shellcheck disable=SC2046
  if [[ -n "$(command -v $(seal::walrus_cli::bin))" ]]; then
    if [[ "${walrus_cli_version}" == "latest" ]]; then
      local expected_md5sum
      expected_md5sum="$(curl --retry 3 --retry-all-errors --retry-delay 3 -IsSfL "https://walrus-cli-1303613262.cos.ap-guangzhou.myqcloud.com/releases/latest/walrus-cli-${os}-${arch}" | grep ETag | cut -d" " -f 2 | sed -e 's/"//g' | sed -e 's/\r//g')"
      local actual_md5sum
      actual_md5sum="$(md5sum $(which $(seal::walrus_cli::bin)) | cut -d" " -f 1)"
      if [[ "${expected_md5sum}" == "${actual_md5sum}" ]]; then
        return 0
      fi
    elif [[ $($(seal::walrus_cli::bin) --version 2>/dev/null | head -n 1 | cut -d " " -f 3 2>&1) == "${walrus_cli_version}" ]]; then
      return 0
    fi
  fi

  seal::log::info "installing walrus-cli ${walrus_cli_version}"
  if seal::walrus_cli::install; then
    seal::log::info "walrus-cli $($(seal::walrus_cli::bin) --version 2>/dev/null | head -n 1)"
    return 0
  fi
  seal::log::error "no walrus-cli"
  return 1
}

function seal::walrus_cli::bin() {
  local bin="walrus-cli"
  if [[ -f "${ROOT_DIR}/.sbin/walrus-cli" ]]; then
    bin="${ROOT_DIR}/.sbin/walrus-cli"
  fi
  echo -n "${bin}"
}

function seal::walrus_cli::schema() {
  if ! seal::walrus_cli::validate; then
    seal::log::error "cannot execute walrus-cli as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  seal::log::info "schema generating ${target} ..."
  $(seal::walrus_cli::bin) schema generate --dir="${target}" "$@" 1>/dev/null
}
