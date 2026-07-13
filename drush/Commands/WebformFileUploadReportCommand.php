<?php

namespace Drush\Commands;

use Consolidation\OutputFormatters\StructuredData\RowsOfFields;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drush\Attributes as CLI;
use Drush\Commands\AutowireTrait;
use Drush\Formatters\FormatterTrait;
use Override;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: self::NAME,
    description: 'Create a report of what forms have file uploads'
)]
#[CLI\FieldLabels(labels: ['wid' => 'Webform ID', 'status' => 'Webform Status', 'archive' => 'Archived'])]
#[CLI\Formatter(returnType: RowsOfFields::class, defaultFormatter: 'table')]
final class WebformFileUploadReport extends Command
{
    use AutowireTrait;
    use FormatterTrait;

    public const string NAME = 'osu:webform-file-upload-report';

    public function __construct(
        private readonly EntityTypeManagerInterface $entityTypeManager,
    ) {
        parent::__construct();
    }

    #[Override]
    public function execute(InputInterface $input, OutputInterface $output): int
    {
        $data = $this->doExecute($input, $output);
        $this->writeFormattedOutput($input, $output, $data);
        return Command::SUCCESS;
    }

    /**
     * Finds all webforms that accept file/media uploads.
     */
    protected function doExecute(InputInterface $input, OutputInterface $output): RowsOfFields
    {
        $webforms = $this->entityTypeManager->getStorage("webform")->loadMultiple();
        $rows = [];
        /**
         * @var \Drupal\webform\Entity\Webform $webformEntity
         */
        foreach ($webforms as $webformId => $webformEntity) {
            $fileElements = $webformEntity->getElementsManagedFiles();
            $allElementsRaw = $webformEntity->getElementsRaw();
            if (count($fileElements) > 0) {
                $rows[$webformId] = [
                    'wid' => $webformId,
                    'status' => $webformEntity->get("status"),
                    'archive' => $webformEntity->get("archive"),
                ];
            } elseif (str_contains($allElementsRaw, 'media_library')) {
                $rows[$webformId] = [
                    'wid' => $webformId,
                    'status' => $webformEntity->get("status"),
                    'archive' => $webformEntity->get("archive"),
                ];
            }
        }
        return (new RowsOfFields($rows));
    }

}
