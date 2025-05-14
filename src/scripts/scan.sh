#!/usr/bin/env bash

set -e
VERSION=5.0.1.3006
SONAR_TOKEN=${SONAR_TOKEN:?Environment variable SONAR_TOKEN is required}
SCANNER_DIRECTORY=/tmp/cache/scanner
export SONAR_USER_HOME=$SCANNER_DIRECTORY/.sonar
OS="linux"
echo "Sonar user home: $SONAR_USER_HOME"

if [[ ! -x "$SCANNER_DIRECTORY/sonar-scanner-$VERSION-$OS/bin/sonar-scanner" ]]; then
  echo "Downloading Sonar Scanner..."
  curl -Ol https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$VERSION-$OS.zip
  unzip -qq -o sonar-scanner-cli-$VERSION-$OS.zip -d $SCANNER_DIRECTORY
fi

chmod +x $SCANNER_DIRECTORY/sonar-scanner-$VERSION-$OS/bin/sonar-scanner
chmod +x $SCANNER_DIRECTORY/sonar-scanner-$VERSION-$OS/jre/bin/java

PROJECT_ROOT=${PROJECT_ROOT:-.}
cd "$PROJECT_ROOT"
echo "Running Sonar Scanner in project root: $PROJECT_ROOT"
$SCANNER_DIRECTORY/sonar-scanner-$VERSION-$OS/bin/sonar-scanner
