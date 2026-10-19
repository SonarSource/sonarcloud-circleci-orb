#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIRECTORY=$(mktemp -d)
trap 'rm -rf "$TEST_DIRECTORY"' EXIT
export SONAR_TOKEN=fake_token
export PROJECT_ROOT="$TEST_DIRECTORY"
export DOWNLOAD_LOG="$TEST_DIRECTORY/downloads"
export SCAN_LOG="$TEST_DIRECTORY/scans"
export SCANNER_VERSION=8.0.1.6346
SCRIPT="$TEST_DIRECTORY/scan.sh"
CACHE="$TEST_DIRECTORY/cache"
sed "s|^SCANNER_DIRECTORY=.*|SCANNER_DIRECTORY='$CACHE'|" "$REPO_ROOT/src/scripts/scan.sh" > "$SCRIPT"

# Mock only external commands; execute the actual script and its cache checks.
uname() { echo "$MOCK_ARCH"; }
curl() {
  echo "${@: -1}" >> "$DOWNLOAD_LOG"
  if [[ ${HTTP_ERROR:-false} == true && $1 == *f* ]]; then
    return 22
  fi
}
unzip() {
  local name="${3#sonar-scanner-cli-}"
  local directory="$5/sonar-scanner-${name%.zip}"
  mkdir -p "$directory/bin" "$directory/jre/bin"
  printf '#!/usr/bin/env bash\necho scanned >> %q\n' "$SCAN_LOG" > "$directory/bin/sonar-scanner"
  touch "$directory/jre/bin/java"
}
export -f uname curl unzip

check_scan() {
  export MOCK_ARCH=$1
  local expected_arch=$2
  rm -rf "$CACHE"
  : > "$DOWNLOAD_LOG"
  : > "$SCAN_LOG"
  bash "$SCRIPT"
  local expected_url="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SCANNER_VERSION-linux-$expected_arch.zip"
  [[ $(< "$DOWNLOAD_LOG") == "$expected_url" ]]
  [[ $(< "$SCAN_LOG") == scanned ]]
  : > "$DOWNLOAD_LOG"
  bash "$SCRIPT"
  [[ ! -s "$DOWNLOAD_LOG" ]]
  [[ $(wc -l < "$SCAN_LOG") -eq 2 ]]
  echo "PASS $MOCK_ARCH / $SCANNER_VERSION: artifact selection and cache reuse"
}

check_scan x86_64 x64
check_scan x64 x64
check_scan amd64 x64
check_scan arm64 aarch64
check_scan aarch64 aarch64
export SCANNER_VERSION=6.2.1.4610
check_scan aarch64 aarch64

for MOCK_ARCH in riscv64 armv7l unknown; do
  export MOCK_ARCH
  : > "$DOWNLOAD_LOG"
  : > "$SCAN_LOG"
  if bash "$SCRIPT" > "$TEST_DIRECTORY/output" 2>&1; then
    echo "Expected unsupported architecture to fail: $MOCK_ARCH" >&2
    exit 1
  fi
  [[ $(< "$TEST_DIRECTORY/output") == *"Unsupported CPU architecture"* ]]
  [[ ! -s "$DOWNLOAD_LOG" && ! -s "$SCAN_LOG" ]]
  echo "PASS unsupported architecture: $MOCK_ARCH"
done

export MOCK_ARCH=aarch64 HTTP_ERROR=true
rm -rf "$CACHE"
if bash "$SCRIPT" > "$TEST_DIRECTORY/output" 2>&1; then
  echo "Expected HTTP failure to stop installation" >&2
  exit 1
fi
[[ ! -d "$CACHE" && ! -s "$SCAN_LOG" ]]
echo "PASS failed download stops installation"
