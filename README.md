# sonarcloud-circleci-orb
Support for SonarScanner CLI in CircleCI

## SonarQube Cloud Orb
The SonarQube Cloud Orb can be used with any Linux-based Docker image that includes the command-line tools `curl` and `unzip`.

### Connecting to the EU region
- To connect to your SonarQube Cloud project on `sonarcloud.io`, you need to set up an API token. We recommend setting up a CircleCI context in your organization named `sonarcloud` that contains a variable with the key `SONAR_TOKEN` and the API token as the value.

### Connecting to the US region
- To connect to your SonarQube Cloud project in the US region, `sonarqube.us`, you need to pass the `sonar.region=US` parameter to the scanner. For this, we recommend adding the `SONAR_REGION` environment variable to your CircleCI context with the value `US`.
- To set up the API token, the recommendation is the same as for the EU region.

### Connecting to the AU region
- To connect to your SonarQube Cloud project in the AU region, `sonarqube.au`, you need to pass the `sonar.region=AU` parameter to the scanner. For this, we recommend adding the `SONAR_REGION` environment variable to your CircleCI context with the value `AU`.
- The AU region requires SonarScanner CLI version `8.4.0.16527` or later, which is the default version used by the orb. If you override the `scanner_version` parameter, make sure you use a version that supports the AU region.
- To set up the API token, the recommendation is the same as for the EU region.

### Usage examples
See files in [the `examples` directory](https://github.com/SonarSource/sonarcloud-circleci-orb/tree/master/src/examples) for examples of how to use the orb.

### Publishing a new version
To publish a new version of the orb, you need to change the version found in `.circleci/config.yml` to the new version. The CircleCI build pipeline will then publish the new version of the orb.

### Requirements
See https://docs.sonarsource.com/sonarqube-cloud/advanced-setup/scanner-environment
