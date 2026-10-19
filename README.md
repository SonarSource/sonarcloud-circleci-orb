# sonarcloud-circleci-orb
Support for SonarScanner CLI in CircleCI

## SonarQube Cloud Orb
The SonarQube Cloud Orb can be used with any Linux-based Docker image that includes the command-line tools `curl` and `unzip`.

Supported CPU architectures are x86-64 and ARM64 (AArch64). The orb selects the
matching Linux SonarScanner CLI distribution, including its bundled Java runtime;
a pre-installed JVM is not required. Other CPU architectures are rejected.
On ARM64, choose a CircleCI Arm resource class, such as `arm.medium`, and a Docker
image that supports ARM64. Custom `scanner_version` values must have a Linux
distribution for the selected architecture (ARM64 distributions start at CLI 6.1).
Scanner caches are isolated by architecture and scanner version.

### Connecting to the EU region
- To connect to your SonarQube Cloud project on `sonarcloud.io`, you need to set up an API token. We recommend setting up a CircleCI context in your organization named `sonarcloud` that contains a variable with the key `SONAR_TOKEN` and the API token as the value.

### Connecting to the US region
- To connect to your SonarQube Cloud project in the US region, `sonarqube.us`, you need to pass the `sonar.region=US` parameter to the scanner. For this, we recommend adding the `SONAR_REGION` environment variable to your CircleCI context with the value `US`.
- To set up the API token, the recommendation is the same as for the EU region.

### Usage examples
See files in [the `examples` directory](https://github.com/SonarSource/sonarcloud-circleci-orb/tree/master/src/examples) for examples of how to use the orb.

### Publishing a new version
To publish a new version of the orb, you need to change the version found in `.circleci/config.yml` to the new version. The CircleCI build pipeline will then publish the new version of the orb.

### Requirements
See https://docs.sonarsource.com/sonarqube-cloud/advanced-setup/scanner-environment

### Testing

Run `bash tests/scan_test.sh` for offline architecture-selection, cache-reuse, and
failed-download checks. CircleCI runs complete analyses with the default scanner
and checks the existing scanner-version override on both x64 and ARM64.
