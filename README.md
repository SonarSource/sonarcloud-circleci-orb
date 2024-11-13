# sonarcloud-circleci-orb
Support of SonarScanner CLI in CircleCI

## SonarQube Cloud Orb
The SonarQube Cloud Orb can be used with any linux based docker image that includes the command line tools `curl` and `unzip`.

To connect to your SonarQube Cloud project on `sonarcloud.io` you need to setup an api token. We recommend to setup a CircleCI context in your organization named `sonarcloud` that contains a variable with key `SONAR_TOKEN` and the api token as the value.
### Usage examples
```yaml
version: 2.1
orbs:
  sonarcloud: sonarsource/sonarcloud@2.0.0
jobs:
  build:
    docker:
      - image: 'circleci/python:3.7.4'
    steps:
    - checkout
    - sonarcloud/scan
workflows:
  my-workflow:
    jobs:
      - build:
          context: sonarcloud
```

### Publishing a new version
To publish a new version of the orb you need to change the version found in .circleci/config.yml to the new version. The CirceCI build pipeline will then publish the new version of the orb.

### Requirements
See https://docs.sonarcloud.io/appendices/scanner-environment/
