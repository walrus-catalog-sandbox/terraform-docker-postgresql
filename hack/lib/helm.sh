#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Helm variables helpers. These functions need the
# following variables:
#
#      HELM_VERSION  -  The Helm version, default is v3.13.1.

helm_version=${HELM_VERSION:-"v3.13.1"}

function seal::helm::helm::install() {
  local os
  os=$(seal::util::get_os)
  local arch
  arch=$(seal::util::get_arch)

  curl --retry 3 --retry-all-errors --retry-delay 3 \
    -o /tmp/helm.tar.gz \
    -sSfL "https://get.helm.sh/helm-${helm_version}-${os}-${arch}.tar.gz"

  tar -zxvf /tmp/helm.tar.gz \
    --directory "${ROOT_DIR}/.sbin" \
    --no-same-owner \
    --strip-components 1 \
    "${os}-${arch}/helm"
  chmod a+x "${ROOT_DIR}/.sbin/helm"
}

function seal::helm::helm::validate() {
  # shellcheck disable=SC2046
  if [[ -n "$(command -v $(seal::helm::helm::bin))" ]]; then
    if [[ $($(seal::helm::helm::bin) version --template="{{ .Version }}" 2>/dev/null | head -n 1) == "${helm_version}" ]]; then
      return 0
    fi
  fi

  seal::log::info "installing helm ${helm_version}"
  if seal::helm::helm::install; then
    seal::log::info "helm $($(seal::helm::helm::bin) version --template="{{ .Version }}" 2>/dev/null | head -n 1)"
    return 0
  fi
  seal::log::error "no helm available"
  return 1
}

function seal::helm::helm::bin() {
  local bin="helm"
  if [[ -f "${ROOT_DIR}/.sbin/helm" ]]; then
    bin="${ROOT_DIR}/.sbin/helm"
  fi
  echo -n "${bin}"
}

function seal::helm::pull() {
  if ! seal::helm::helm::validate; then
    seal::log::error "cannot execute helm as it hasn't installed"
    return 1
  fi

  local target="$1"
  local destination="$2"

  local args=()
  if [[ "${target%%:*}" == "${target%:*}" ]]; then
    args=("${target}")
  else 
    args=(
      "${target%:*}"
      "--version=${target##*:}"
    )
    case "${target%%:*}" in
    oci)
      if [[ -f "${destination}/$(basename "${target}" | sed 's/:/-/g').tgz" ]]; then
        return 0
      fi
    ;;
    esac
  fi
  args+=("--destination=${destination}")

  mkdir -p "${destination}"
  seal::log::info "pulling ${target} chart ..."
  $(seal::helm::helm::bin) pull "${args[@]}"
}
