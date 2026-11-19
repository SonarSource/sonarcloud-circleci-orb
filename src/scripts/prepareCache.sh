#!/usr/bin/env bash

set -e
mkdir -p /tmp/cache/scanner
case "$(uname -m)" in
  arm64 | aarch64) echo aarch64 ;;
  *) echo x64 ;;
esac > /tmp/sonar-scanner-arch
