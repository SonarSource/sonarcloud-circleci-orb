#!/usr/bin/env bash

set -e
VERSION=7.1.0.4889
SONAR_TOKEN=${SONAR_TOKEN:?Environment variable SONAR_TOKEN is required}
SCANNER_DIRECTORY=/tmp/cache/scanner
export SONAR_USER_HOME=$SCANNER_DIRECTORY/.sonar
OS="linux"
ARCH="x64"
VERSION_OS_ARCH="$VERSION-$OS-$ARCH"
echo "Sonar user home: $SONAR_USER_HOME"

if [[ ! -x "$SCANNER_DIRECTORY/sonar-scanner-$VERSION_OS_ARCH/bin/sonar-scanner" ]]; then
  echo "Downloading Sonar Scanner..."
  curl -Ol https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$VERSION_OS_ARCH.zip
  unzip -qq -o sonar-scanner-cli-$VERSION_OS_ARCH.zip -d $SCANNER_DIRECTORY
fi

chmod +x $SCANNER_DIRECTORY/sonar-scanner-$VERSION_OS_ARCH/bin/sonar-scanner
chmod +x $SCANNER_DIRECTORY/sonar-scanner-$VERSION_OS_ARCH/jre/bin/java

PROJECT_ROOT=${PROJECT_ROOT:-.}
cd "$PROJECT_ROOT"
echo "Running Sonar Scanner in project root: $PROJECT_ROOT"
$SCANNER_DIRECTORY/sonar-scanner-$VERSION_OS_ARCH/bin/sonar-scanner
