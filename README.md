# Oregon State University Drupal
This is the main OSU Drupal Distribution.
## Update and deploy to Acquia
[Acquia Pipelines](https://docs.acquia.com/cloud-platform/pipelines/) will watch, build, and deploy versions when changes are detected.
- The develop branch will build and deploy to Acquia Cloud Development environment
- The master branch will build and deploy the Acquia Cloud Stage environment.
- For Acquia Cloud Production an Acquia Cloud administrator will need to manually deploy code from the Stage environment to Production.
### Update workflow
1. Start in the development branch
   1. ```git pull && composer install```
   2. Check for updates ```composer outdated drupal/\*```
      1. If you want to only check for packages that have minor version updates
         1. ```composer outdated -m drupal/\*```
      2. To check for only updates that are required by this distribution's composer.json
         1. ```composer outdated -D drupal/\*```
   3. Get updates
      1. To update a specific package only
         1. ```composer update vendor/package```
            1. eg ```composer update drupal/my_module```
      2. Update only core and it's dependencies
         1. ```composer update drupal/core-composer-scaffold drupal/core-recommended drupal/core-dev --with-all-dependencies```
      3. Get all updates
         1. ```composer update```
   4. Commit the changed composer.json and composer.lock and push
   5. Checkout the master branch
      1. ```git pull && composer install```
      2. Merge the development branch in
      3. Commit and push
   6. Log into Acquia Cloud
      1. Navigate to the Acquia Cloud Application and deploy the latest changes to prod from the Stage environment.

## Local Development
You can build the container locally or pull form the registry.
### Building Container
We have a multi-stage Docker file to build. Most of the time the Development version will be used.
- For the development version of the container:
  - ```docker build --target=development --tag=osuwams/drupal:8-apache-dev .```
- For the Production version
  - ```docker build --target=production --tag=osuwams/drupal:8-apache .```
