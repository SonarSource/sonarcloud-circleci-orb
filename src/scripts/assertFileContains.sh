#!/bin/bash

set -eo pipefail

error() { echo -e "\\e[31m✗ $*\\e[0m"; }

. "${BASH_SOURCE%/*}"/assertFileExists.sh "$1"

if ! grep -q "$2" "$1"; then
  error "'$2' not found in '$1'"
  cat "$1"
  exit 1
fi
