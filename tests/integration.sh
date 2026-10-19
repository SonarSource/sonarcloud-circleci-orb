#!/usr/bin/env bash
# Run in a disposable Linux container with curl, unzip, and no system Java.
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
if command -v java; then
  echo "This test requires an image without system Java" >&2
  exit 1
fi
test ! -d /tmp/cache/scanner
# The orb creates this directory before invoking scan.sh.
mkdir -p /tmp/cache/scanner
TEST_DIRECTORY=$(mktemp -d)
trap 'rm -rf "$TEST_DIRECTORY"' EXIT
export PROJECT_ROOT="$TEST_DIRECTORY/project with spaces"
mkdir -p "$PROJECT_ROOT"
cd "$TEST_DIRECTORY"
export SCANNER_VERSION=${SCANNER_VERSION:-8.0.1.6346}
export SONAR_TOKEN=fake_token
export SONAR_REGION=US
export SONAR_SCANNER_JSON_PARAMS='{"sonar.scanner.internal.dumpToFile":"./output.properties"}'

echo "Cold cache: $(uname -m), scanner $SCANNER_VERSION"
bash "$REPO_ROOT/src/scripts/scan.sh"
bash "$REPO_ROOT/src/scripts/assertFileContains.sh" "$PROJECT_ROOT/output.properties" "sonar.scanner.appVersion=$SCANNER_VERSION"
# The older compatibility-test version predates US-region support.
if [[ "$SCANNER_VERSION" == 8.0.1.6346 ]]; then
  bash "$REPO_ROOT/src/scripts/assertFileContains.sh" "$PROJECT_ROOT/output.properties" "sonar.region=US"
fi
bash "$REPO_ROOT/src/scripts/assertFileContains.sh" "$PROJECT_ROOT/output.properties" "project with spaces"

# Make a second download fail, proving the installed scanner is reused.
curl() {
  echo "Unexpected download with a warm cache" >&2
  return 1
}
export -f curl
rm "$PROJECT_ROOT/output.properties"
echo "Warm cache: $(uname -m), scanner $SCANNER_VERSION"
bash "$REPO_ROOT/src/scripts/scan.sh"
test -s "$PROJECT_ROOT/output.properties"
