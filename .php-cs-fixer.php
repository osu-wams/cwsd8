<?php

declare(strict_types=1);

use drupol\PhpCsFixerConfigsDrupal\Config\Drupal8;
use PhpCsFixer\Finder;
use PhpCsFixer\Runner\Parallel\ParallelConfigFactory;

$finder = Finder::create()
  ->in(__DIR__)
  ->name('*.php')
  ->name('*.module')
  ->name('*.inc')
  ->name('*.install')
  ->name('*.profile')
  ->name('*.theme')
  ->notPath('*.md')
  ->notPath('*.yml')
  ->exclude('drush')
  ->exclude('tests')
  ->exclude('node_modules');

$config = new Drupal8();

$config->setParallelConfig(ParallelConfigFactory::detect());
$config->setFinder($finder);

$rules = $config->getRules();
$rules['declare_strict_types'] = true;
$rules['blank_line_after_opening_tag'] = true;
$rules['ordered_imports'] = true;

$config->setRules($rules);

return $config;
