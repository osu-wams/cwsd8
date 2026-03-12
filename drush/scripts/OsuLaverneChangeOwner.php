<?php

namespace OSU\Drush\Commands;

use Consolidation\OutputFormatters\StructuredData\RowsOfFields;
use Drush\Attributes as CLI;
use Drush\Commands\AutowireTrait;
use Drush\Formatters\FormatterTrait;
use Drush\Psysh\DrushCommand;
use Symfony\Component\Console\Attribute\AsCommand;

#[AsCommand(
  name: self::NAME,
  description: 'Drush command for interacting with the ShURLy Module',
)]
#[CLI\FieldLabels(labels: ['template' => 'Template', 'compiled' => 'Compiled'])]
#[CLI\DefaultTableFields(fields: ['template', 'compiled'])]
#[CLI\FilterDefaultField(field: 'template')]
#[CLI\Formatter(returnType: RowsOfFields::class, defaultFormatter: 'table')]
final class OsuLaverneCommands extends DrushCommand {

  use AutowireTrait;
  use FormatterTrait;

  public function __construct() {
    parent::__construct();
  }
}
