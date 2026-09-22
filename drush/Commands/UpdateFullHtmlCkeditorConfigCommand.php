<?php

namespace Drush\Commands;

use Drupal\Core\Config\FileStorage;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Extension\ModuleHandlerInterface;
use Drush\Commands\AutowireTrait;
use Override;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: self::NAME,
    description: 'Update Full HTML CKEditor Config for a site.'
)]
final class UpdateFullHtmlCkeditorConfigCommand extends Command
{
    use AutowireTrait;

    public const string NAME = 'osu:cke-full-html-update';

    public function __construct(
        private readonly EntityTypeManagerInterface $entityTypeManager,
        private readonly ModuleHandlerInterface $moduleHandler,
    ) {
        parent::__construct();
    }

    #[Override]
    public function execute(InputInterface $input, OutputInterface $output): int
    {
        $this->doExecute($input, $output);
        return Command::SUCCESS;
    }

    /**
     * Do the work.
     *
     * @param  InputInterface  $input
     * @param  OutputInterface $output
     * @return void
     */
    public function doExecute(InputInterface $input, OutputInterface $output): void
    {
        $stylesRemove = [
            'Bordered Table',
            'Borderless Table',
            'Hover Table',
            'Striped Table',
            'Striped Columns',
            'Cell Active',
            'Row Active',
        ];
        $editorStorage = $this->entityTypeManager->getStorage('editor');
        $installProfilePath = $this->moduleHandler->getModule('osu_standard')->getPath();
        $installProfileConfigPath = realpath($installProfilePath . '/config/install');
        $fileStorage = new FileStorage($installProfileConfigPath);
        $defaultEditor = $fileStorage->read('editor.editor.full_html');
        /**
         * @var \Drupal\editor\Entity\Editor $editor
         */
        $editor = $editorStorage->load('full_html');
        $editorSettings = $editor->getSettings();
        // Replace the seperator after link with a link break,
        $linkButtonPos = array_search('link', $editorSettings['toolbar']['items']);
        if ($editorSettings['toolbar']['items'][$linkButtonPos + 1] === '|') {
            $editorSettings['toolbar']['items'][$linkButtonPos + 1] = '-';
        }
        $headingDropDownPos = array_search('heading', $editorSettings['toolbar']['items']);
        if ($editorSettings['toolbar']['items'][$headingDropDownPos + 1] === '|') {
            unset($editorSettings['toolbar']['items'][$headingDropDownPos + 1]);
        }
        // Update Advnaced Link options.
        $editorSettings['plugins']['editor_advanced_link_link']['enabled_attributes'] = [
            "aria-label",
            "class",
        ];
        $editorStyles = $editorSettings['plugins']['ckeditor5_style'];
        $editorSettings['plugins']['ckeditor5_style']['styles'] = array_filter($editorStyles['styles'], static fn($arr) => !in_array($arr['label'], $stylesRemove));
        // Update the link styles completly.
        $editorSettings['plugins']['ckeditor_link_styles_linkStyles']['styles'] = $defaultEditor['settings']['plugins']['ckeditor_link_styles_linkStyles']['styles'];
        $editor->set('settings', $editorSettings);
        $editor->save();
        // We have to update the Allowed HTML Tags when we make changes to the Styles dropdown.
        $filter = $editor->getFilterFormat();
        $filterFilters = $filter->get('filters');
        $allowedHtmlTags = $filterFilters['filter_html']['settings']['allowed_html'];
        // Only find the Table styles;
        $pattern = "/<table class=\\\".*\\\">/mU";
        $allowedHtmlTags = preg_replace_callback($pattern, fn($matches) => preg_replace("/\stable-(?!sm|orange)\w+-?\w+/m", '', $matches[0]), $allowedHtmlTags);
        // Remove the TD and TR styles completly.
        $allowedHtmlTags = str_replace("<td class=\"table-active\"> <tr class=\"table-active\">", '', $allowedHtmlTags);
        $filterFilters['filter_html']['settings']['allowed_html'] = $allowedHtmlTags;
        $filter->set('filters', $filterFilters);
        $filter->save();
    }

}
