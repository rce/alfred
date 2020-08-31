#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
repo="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export PYTHON_VERSION="3.8.5"

function main {
  cd "$repo"

  use_python_version "$PYTHON_VERSION"
  install_python_dependencies

  ansible --version
  ansible-playbook \
    --diff \
    --ask-become-pass \
    --inventory alfred, \
    playbook.yml
}

function use_python_version {
  require_command pyenv

  local version="$1"
  eval "$( pyenv init - )"
  pyenv install --skip-existing "$version"
  pyenv local "$version"
  python -m pip install pipenv
}

function install_python_dependencies {
  python -m pipenv install
  source "$( python -m pipenv --venv )/bin/activate"
}

function require_command  {
  command -v $1 &> /dev/null || fail "Command $1 is required"
}

function fail {
  echo >&2 "$@"
  exit 1
}

main "$@"
