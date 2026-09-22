<?php

namespace Drush\Commands;

use Composer\Console\Input\InputArgument;
use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\Core\Config\FileStorage;
use Drupal\Core\Extension\ModuleHandlerInterface;
use Drush\Commands\AutowireTrait;
use Drush\Style\DrushStyle;
use Override;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: self::NAME,
    description: 'Syncronize CKEditor configs from the Install Profile'
)]
final class SyncCkeditorConfigsCommand extends Command
{
    use AutowireTrait;

    public const string NAME = 'osu:cke-sync';

    public function __construct(
        private readonly ConfigFactoryInterface $configFactory,
        private readonly ModuleHandlerInterface $moduleHandler
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this->addArgument('editor', InputArgument::REQUIRED, 'The Editor ID to syncronize');
        $this->setHelp('Syncronize the Editor Settings from the Install Profile');
    }

    #[Override]
    public function execute(InputInterface $input, OutputInterface $output): int
    {
        $io = new DrushStyle($input, $output);
        $this->doExecute($input, $output);
        $mesage = \sprintf("CKEditor updated for editor %s", $input->getArgument('editor'));
        $io->writeln($mesage);
        return Command::SUCCESS;
    }

    public function doExecute(InputInterface $input, OutputInterface $output): void
    {
        // Load the Require argument
        $editorId = $input->getArgument('editor');
        // Get the correct path to our Configuration Folder.
        $installProfilePath = $this->moduleHandler->getModule('osu_standard')->getPath();
        $installProfileConfigPath = realpath($installProfilePath . '/config/install');
        $fileStorage = new FileStorage($installProfileConfigPath);
        // Load the confiuration files into memory.
        $defaultEditor = $fileStorage->read("editor.editor.{$editorId}");
        $defaultFilter = $fileStorage->read("filter.format.{$editorId}");
        // Update the Editor.
        $activeEditorConfig = $this->configFactory->getEditable("editor.editor.{$editorId}");
        $activeEditorConfig->set('settings', $defaultEditor['settings']);
        $activeEditorConfig->save();
        // Update the filter format.
        $activeFilterConfig = $this->configFactory->getEditable("filter.format.{$editorId}");
        $activeFilterConfig->set('filters', $defaultFilter['filters']);
        $activeFilterConfig->save();

    }
}
