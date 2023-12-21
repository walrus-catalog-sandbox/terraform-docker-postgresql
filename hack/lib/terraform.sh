#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Terraform variables helpers. These functions need the
# following variables:
#
#      TERRAFORM_VERSION  -  The Terraform version, default is v1.6.2.
# TERRAFORM_DOCS_VERSION  -  The Terraform docs version, default is v0.16.0.
#         TFLINT_VERSION  -  The TFLint version, default is v0.48.0.
#          TFSEC_VERSION  -  The TFSec version, default is v1.28.4.

terraform_version=${TERRAFORM_VERSION:-"v1.6.2"}
terraform_docs_version=${TERRAFORM_DOCS_VERSION:-"v0.16.0"}
tflint_version=${TFLINT_VERSION:-"v0.48.0"}
tfsec_version=${TFSEC_VERSION:-"v1.28.4"}

function seal::terraform::terraform::install() {
  local os
  os=$(seal::util::get_os)
  local arch
  arch=$(seal::util::get_arch)
  
  curl --retry 3 --retry-all-errors --retry-delay 3 \
    -o /tmp/terraform.zip \
    -sSfL "https://releases.hashicorp.com/terraform/${terraform_version#v}/terraform_${terraform_version#v}_${os}_${arch}.zip"
  
  unzip -qu /tmp/terraform.zip -d "${ROOT_DIR}/.sbin"
  chmod a+x "${ROOT_DIR}/.sbin/terraform"
}

function seal::terraform::terraform::validate() {
  # shellcheck disable=SC2046
  if [[ -n "$(command -v $(seal::terraform::terraform::bin))" ]]; then
    if [[ $($(seal::terraform::terraform::bin) version 2>/dev/null | head -n 1 | cut -d " " -f 2 2>&1) == "${terraform_version}" ]]; then
      return 0
    fi
  fi

  seal::log::info "installing terraform ${terraform_version}"
  if seal::terraform::terraform::install; then
    seal::log::info "terraform $($(seal::terraform::terraform::bin) version 2>/dev/null | head -n 1 | cut -d " " -f 2 2>&1)"
    return 0
  fi
  seal::log::error "no terraform available"
  return 1
}

function seal::terraform::terraform::bin() {
  local bin="terraform"
  if [[ -f "${ROOT_DIR}/.sbin/terraform" ]]; then
    bin="${ROOT_DIR}/.sbin/terraform"
  fi
  echo -n "${bin}"
}

function seal::terraform::format() {
  if ! seal::terraform::terraform::validate; then
    seal::log::error "cannot execute terraform as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  local extra_args=("-no-color")
  if [[ "${WITH_COLOR:-true}" == "true" ]]; then
    extra_args=()
  fi

  $(seal::terraform::terraform::bin) -chdir="${target}" fmt -diff "${extra_args[@]}" "$@"
}

function seal::terraform::validate() {
  if ! seal::terraform::terraform::validate; then
    seal::log::error "cannot execute terraform as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  local extra_args=("-no-color")
  if [[ "${WITH_COLOR:-true}" == "true" ]]; then
    extra_args=()
  fi

  seal::log::info "validating ${target} ..."
  $(seal::terraform::terraform::bin) -chdir="${target}" init "${extra_args[@]}" -upgrade 1>/dev/null
  $(seal::terraform::terraform::bin) -chdir="${target}" validate "${extra_args[@]}" "$@"
}

function seal::terraform::test() {
  if ! seal::terraform::terraform::validate; then
    seal::log::error "cannot execute terraform as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  local extra_args=("-no-color")
  if [[ "${WITH_COLOR:-true}" == "true" ]]; then
    extra_args=()
  fi

  seal::log::info "testing ${target} ..."
  $(seal::terraform::terraform::bin) -chdir="${target}" init "${extra_args[@]}" -upgrade 1>/dev/null
  $(seal::terraform::terraform::bin) -chdir="${target}" test "${extra_args[@]}" "$@"
}

function seal::terraform::docs::install() {
  local os
  os=$(seal::util::get_os)
  local arch
  arch=$(seal::util::get_arch)
  
  curl --retry 3 --retry-all-errors --retry-delay 3 \
    -o /tmp/terraform-docs.tar.gz \
    -sSfL "https://terraform-docs.io/dl/${terraform_docs_version}/terraform-docs-${terraform_docs_version}-${os}-${arch}.tar.gz"
  
  tar -zxvf /tmp/terraform-docs.tar.gz \
    --directory "${ROOT_DIR}/.sbin" \
    --no-same-owner \
    --exclude ./LICENSE \
    --exclude ./*.md
  chmod a+x "${ROOT_DIR}/.sbin/terraform-docs"
}

function seal::terraform::docs::validate() {
  # shellcheck disable=SC2046
  if [[ -n "$(command -v $(seal::terraform::docs::bin))" ]]; then
    if [[ $($(seal::terraform::docs::bin) version 2>/dev/null | head -n 1 | cut -d " " -f 3) == "${terraform_docs_version}" ]]; then
      return 0
    fi
  fi

  seal::log::info "installing terraform-docs ${terraform_docs_version}"
  if seal::terraform::docs::install; then
    seal::log::info "terraform-docs $($(seal::terraform::docs::bin) version 2>/dev/null | head -n 1 | cut -d " " -f 3)"
    return 0
  fi
  seal::log::error "no terraform-docs available"
  return 1
}

function seal::terraform::docs::bin() {
  local bin="terraform-docs"
  if [[ -f "${ROOT_DIR}/.sbin/terraform-docs" ]]; then
    bin="${ROOT_DIR}/.sbin/terraform-docs"
  fi
  echo -n "${bin}"
}

function seal::terraform::docs() {
  if ! seal::terraform::docs::validate; then
    seal::log::error "cannot execute terraform-docs as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  seal::log::info "docing ${target} ..."
  $(seal::terraform::docs::bin) "$@" "${target}" 1>/dev/null
}

function seal::terraform::lint::install() {
  local os
  os=$(seal::util::get_os)
  local arch
  arch=$(seal::util::get_arch)
  
  curl --retry 3 --retry-all-errors --retry-delay 3 \
    -o /tmp/tflint.zip \
    -sSfL "https://github.com/terraform-linters/tflint/releases/download/${tflint_version}/tflint_${os}_${arch}.zip"
  
  unzip -qu /tmp/tflint.zip -d "${ROOT_DIR}/.sbin"
  chmod a+x "${ROOT_DIR}/.sbin/tflint"
}

function seal::terraform::lint::validate() {
  # shellcheck disable=SC2046
  if [[ -n "$(command -v $(seal::terraform::lint::bin))" ]]; then
    if [[ $($(seal::terraform::lint::bin) --version 2>/dev/null | head -n 1 | cut -d " " -f 3) == "${tflint_version#v}" ]]; then
      return 0
    fi
  fi

  seal::log::info "installing tflint ${tflint_version}"
  if seal::terraform::lint::install; then
    seal::log::info "tflint v$($(seal::terraform::lint::bin) --version 2>/dev/null | head -n 1 | cut -d " " -f 3)"
    return 0
  fi
  seal::log::error "no tflint available"
  return 1
}

function seal::terraform::lint::bin() {
  local bin="tflint"
  if [[ -f "${ROOT_DIR}/.sbin/tflint" ]]; then
    bin="${ROOT_DIR}/.sbin/tflint"
  fi
  echo -n "${bin}"
}

function seal::terraform::lint() {
  if ! seal::terraform::lint::validate; then
    seal::log::error "cannot execute tflint as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  local extra_args=("--no-color")
  if [[ "${WITH_COLOR:-true}" == "true" ]]; then
    extra_args=()
  fi
  if [[ "${WITH_FIX:-false}" == "true" ]]; then
    extra_args+=("--fix")
  fi

  seal::log::info "linting ${target} ..."
  $(seal::terraform::lint::bin) --init "${extra_args[@]}" 1>/dev/null
  $(seal::terraform::lint::bin) "${extra_args[@]}" "$@"
}

function seal::terraform::sec::install() {
  local os
  os=$(seal::util::get_os)
  local arch
  arch=$(seal::util::get_arch)
  
  curl --retry 3 --retry-all-errors --retry-delay 3 \
    -o /tmp/tfsec.tar.gz \
    -sSfL "https://github.com/aquasecurity/tfsec/releases/download/${tfsec_version}/tfsec_${tfsec_version#v}_${os}_${arch}.tar.gz"
  
  tar -zxvf /tmp/tfsec.tar.gz \
    --directory "${ROOT_DIR}/.sbin" \
    --no-same-owner \
    --exclude ./LICENSE \
    --exclude ./*.md
  chmod a+x "${ROOT_DIR}/.sbin/tfsec"
  chmod a+x "${ROOT_DIR}/.sbin/tfsec-checkgen"
}

function seal::terraform::sec::validate() {
  # shellcheck disable=SC2046
  if [[ -n "$(command -v $(seal::terraform::sec::bin))" ]]; then
    if [[ $($(seal::terraform::sec::bin) --version 2>/dev/null | head -n 1) == "${tfsec_version}" ]]; then
      return 0
    fi
  fi

  seal::log::info "installing tfsec ${tfsec_version}"
  if seal::terraform::sec::install; then
    seal::log::info "tfsec v$($(seal::terraform::sec::bin) --version 2>/dev/null | head -n 1)"
    return 0
  fi
  seal::log::error "no tfsec available"
  return 1
}

function seal::terraform::sec::bin() {
  local bin="tfsec"
  if [[ -f "${ROOT_DIR}/.sbin/tfsec" ]]; then
    bin="${ROOT_DIR}/.sbin/tfsec"
  fi
  echo -n "${bin}"
}

function seal::terraform::sec() {
  if ! seal::terraform::sec::validate; then
    seal::log::error "cannot execute tfsec as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  local extra_args=("--no-color")
  if [[ "${WITH_COLOR:-true}" == "true" ]]; then
    extra_args=()
  fi

  seal::log::info "securing ${target} ..."
  $(seal::terraform::sec::bin) "${target}" --format="text" "${extra_args[@]}" "$@" 
}
