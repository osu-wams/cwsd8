<?php

namespace osuwams;

use Composer\Script\Event;

class SiteGenerator {

  /**
   * Generate a Drupal site config and update sites mapping file.
   *
   * @param \Composer\Script\Event $event
   */
  public static function generate(Event $event) {
    $io = $event->getIO();
    $baseDir = getcwd();
    $siteName = strtolower($io->ask('Site Production FQDN: '));
    if (!is_dir($baseDir . "/docroot/sites/{$siteName}")) {
      // Match any character that is not a word.
      $databaseName = preg_replace('/[\W]+/', '_', $siteName);
      mkdir($baseDir . "/docroot/sites/{$siteName}");
      $settingsFile = file_get_contents($baseDir . "/scripts/site-template/settings.php");
      $settingsFile = str_replace("DOMAIN", $databaseName, $settingsFile);
      file_put_contents($baseDir . "/docroot/sites/{$siteName}/settings.php", $settingsFile);
      // Update sites.php file with new domain
      /* @var $sites */
      include($baseDir . '/docroot/sites/sites.php');
      // Check to ensure domain doesn't already exist in sites.php.
      if (!in_array($siteName, $sites)) {
        $siteSubName = explode('.', $siteName);
        $sites["{$siteSubName[0]}.dev.oregonstate.edu"] = $siteName;
        $sites["{$siteSubName[0]}.stage.oregonstate.edu"] = $siteName;
      }
      ksort($sites);
      $string = '<?php' . PHP_EOL;
      file_put_contents($baseDir . '/docroot/sites/sites.php', $string);
      foreach ($sites as $key => $value) {
        $siteString = "\$sites['{$key}'] = '{$value}';" . PHP_EOL;
        file_put_contents($baseDir . '/docroot/sites/sites.php', $siteString, FILE_APPEND);
      }
      $postInstallSteps = [
        "Post Script Steps:",
        "Log into Acquia Cloud and Create the following Database and Domains:",
        "Database: {$databaseName}",
        "Dev Domain: {$siteSubName[0]}.dev.oregonstate.edu",
        "Test Domain: {$siteSubName[0]}.stage.oregonstate.edu",
        "Prod Domain: {$siteName}",
      ];
      $io->write($postInstallSteps);
    }
    else {
      $io->writeError('Site Already exists');
    }
  }

}
