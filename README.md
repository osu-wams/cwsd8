# Oregon State University Drupal

This is the main OSU Drupal Distribution.

## Update and deploy to Acquia

[Acquia Pipelines](https://docs.acquia.com/cloud-platform/pipelines/) will watch, build, and deploy versions when
changes are detected.

- The develop branch will build and deploy to Acquia Cloud Development environment
- The master branch will build and deploy the Acquia Cloud Stage environment.
- For Acquia Cloud Production an Acquia Cloud administrator will need to manually deploy code from the Stage environment
  to Production.

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

## Create New Acquia Cloud Site

1. To create a new site in OSU Drupal for Acquia Cloud run ```composer generate-site```
2. This will ask you for the Production FQDN of the site to use and will create the sites' directory, populate the
   settings.php and the memcache file for acquia cloud.
3. Follow the Post Install steps to Create the Database and Domains.

## Local Development

You can build the container locally or pull form the registry.

### Building Container

We have a multi-stage Docker file to build. Most of the time the Development version will be used.

- For the development version of the container:
  - ```docker build --target=development --tag=osuwams/drupal:9-apache-dev .```
- For the Production version
  - ```docker build --target=production --tag=osuwams/drupal:9-apache .```

## Environment Variables that can be set

### The Main variable for the Drupal Site.

- DRUPAL_DBNAME
  - The Database Name to use
- DRUPAL_DBUSER
  - The Database User with permissions to that Database.
- DRUPAL_DBPASS
  - The Password to the Database User.

#### Optional Parameters

- DRUPAL_DBHOST
  - The Host name that the Database Server is running on
    - Default: localhost
- DRUPAL_DBPORT
  - The Port the Database Server is running on
    - Default: 3306

### Environment Variables For Migrations

- DRUPAL_MIGRATE_DBNAME
  - The Database Name that contains the Source Data for the Migration
- DRUPAL_MIGRATE_DBUSER
  - The Database user with permissions to that Database
- DRUPAL_MIGRATE_DBPASS
  - The Password for the Database User

#### Optional Parameters

- DRUPAL_MIGRATE_DBHOST
  - The Host name that the Database Server is running on
    - Default: localhost
- DRUPAL_MIGRATE_DBPORT
  - The Port the Database Server is running on
    - Default: 3306

## Setting Up the Migration Database

If you are running migrations locally after copying Down the database and files from the servers. Exec into the Database
Container and create a new database and assign the same user to have access
You can set the database name to what you will use in your Docker Compose environment variables.

For this example lets
assume we want to migrate from drupal.oregonstate.edu and our Database user we used when we set up our Database
container
is 'drupal'.

```sql
CREATE DATABASE drupal_oregonstate_edu CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON `drupal_oregonstate_edu`.* TO `drupal`@`%`;
```

Copy the Database file into the Drupal Container. This assumes the Drupal service is defined as `drupal`
```shell
docker compose cp drupal_oregonstate_edu.sql drupal:/var/www/
```
Import the Migrate source Database into the newly created Database. This assumes the Database service is defined as `database`
```shell
mysql -u drupal -p -h database drupal_oregonstate_edu < drupal_oregonstate_edu.sql
```

To place all files from the source drupal site for Files migration copy them to:

```shell
docker compose cp drupal.oregonstate.edu drupal:/var/www/html/docroot/sites/
```
