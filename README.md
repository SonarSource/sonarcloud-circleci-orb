# sonarcloud-circleci-orb
Support for SonarScanner CLI in CircleCI

## SonarQube Cloud Orb
The SonarQube Cloud Orb can be used with any Linux-based Docker image that includes the command-line tools `curl` and `unzip`.

The orb supports Linux x64 and ARM64 executors.

### Connecting to SonarQube Cloud
- To connect to your SonarQube Cloud project, you need to set up an API token. We recommend setting up a CircleCI context in your organization named `sonarcloud` that contains a variable with the key `SONAR_TOKEN` and the API token as the value.
- To connect to a region other than the default EU region, you need to pass the `sonar.region` parameter to the scanner. For this, we recommend adding the `SONAR_REGION` environment variable to your CircleCI context with the value of the region.

| Region | URL              | `SONAR_REGION` value | Minimum SonarScanner CLI version |
|--------|------------------|----------------------|----------------------------------|
| EU     | `sonarcloud.io`  | (not set)            | Any                              |
| US     | `sonarqube.us`   | `US`                 | `7.1.0.4889`                     |
| AU     | `sonarqube.au`   | `AU`                 | `8.4.0.16527`                    |

The orb uses a default SonarScanner CLI version that supports all regions. If you override the `scanner_version` parameter, make sure you use a version that supports your region.

### Usage examples
See files in [the `examples` directory](https://github.com/SonarSource/sonarcloud-circleci-orb/tree/master/src/examples) for examples of how to use the orb.

### Publishing a new version
To publish a new version of the orb, you need to change the version found in `.circleci/config.yml` to the new version. The CircleCI build pipeline will then publish the new version of the orb.

### Requirements
See https://docs.sonarsource.com/sonarqube-cloud/advanced-setup/scanner-environment
