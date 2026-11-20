<!-- Sonar Marketing hosts these approved brand assets on its Kentico Kontent CDN (assets-eu-01.kc-usercontent.com). Shared URLs are intentional; consult Marketing before replacing them. -->
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://assets-eu-01.kc-usercontent.com/ef593040-b591-0198-9506-ed88b30bc023/a23fc7ba-23f0-489a-829d-ed88c0748521/Sonar_Logo_Dark%20Backgrounds.svg">
    <img src="https://assets-eu-01.kc-usercontent.com/ef593040-b591-0198-9506-ed88b30bc023/82c13eba-d95c-4bb8-8007-7ce77c14e043/Sonar_Logo_Light%20Backgrounds.svg" alt="Sonar logo" width="400">
  </picture>
</p>

<!-- sonar-marketing:start -->
<!-- Marketing maintains this section. For wording changes, consult the relevant Product Marketing Manager (PMM). Repository CODEOWNERS review accuracy and merge changes. -->

# SonarQube Cloud orb for CircleCI

This orb runs SonarScanner CLI in CircleCI workflows to analyze projects with SonarQube Cloud.

Learn more about [SonarQube Cloud](https://www.sonarsource.com/products/sonarqube/cloud/).

<!-- sonar-marketing:end -->

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
