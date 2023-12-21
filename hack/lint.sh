#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${ROOT_DIR}/hack/lib/init.sh"

function check_dirty() {
  [[ "${LINT_DIRTY:-false}" == "true" ]] || return 0

  if [[ -n "$(command -v git)" ]]; then
    if git_status=$(git status --porcelain 2>/dev/null) && [[ -n ${git_status} ]]; then
      seal::log::fatal "the git tree is dirty:\n$(git status --porcelain)"
    fi
  fi
}

function lint() {
  local target="$1"
  shift 1

  if [[ $# > 0 ]]; then
    for subdir in "$@"; do
      local path="${target}/${subdir}"
      local tfs
      tfs=$(seal::util::find_files "${path}" "*.tf")
      
      if [[ -n "${tfs}" ]]; then
        seal::terraform::format "${path}"
        seal::terraform::validate "${path}"
        seal::terraform::lint "${path}"
        seal::terraform::sec "${path}" --config-file="${target}/.tfsec.yml"
      else
        seal::log::warn "There is no Terraform files under ${path}"
      fi
    done
    
    return 0
  fi

  seal::terraform::format "${target}" -recursive

  seal::terraform::validate "${target}"

  if [[ -d "${target}/examples" ]]; then
    local examples=()
    # shellcheck disable=SC2086
    IFS=" " read -r -a examples <<<"$(seal::util::find_subdirs ${target}/examples)"
    for example in "${examples[@]}"; do
      seal::terraform::validate "${target}/examples/${example}"
    done
  fi

  if [[ -d "${target}/modules" ]]; then
    local modules=()
    # shellcheck disable=SC2086
    IFS=" " read -r -a modules <<<"$(seal::util::find_subdirs ${target}/modules)"
    for module in "${modules[@]}"; do
      seal::terraform::validate "${target}/modules/${module}"
    done
  fi

  if [[ -d "${target}/tests" ]]; then
    local tests=()
    # shellcheck disable=SC2086
    IFS=" " read -r -a tests <<<"$(seal::util::find_subdirs ${target}/tests)"
    for test in "${tests[@]}"; do
      seal::terraform::validate "${target}/tests/${test}"
    done
  fi

  seal::terraform::lint "${target}" --recursive

  seal::terraform::sec "${target}" --config-file="${target}/.tfsec.yml"
}

function after() {
  check_dirty
}

#
# main
#

seal::log::info "+++ LINT +++"

lint "${ROOT_DIR}" "$@"

after

seal::log::info "--- LINT ---"
