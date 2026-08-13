<?php

namespace Drush\Commands;

use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\Core\DependencyInjection\AutowireTrait;
use Drush\Style\DrushStyle;
use Override;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: self::NAME,
    description: 'Fix the allow other condition in Block Visibility Groups'
)]
final class BVGFixConditionCommand extends Command
{
    use AutowireTrait;

    public const string NAME = 'osu:bvg-fix-condition';

    public function __construct(
        private readonly ConfigFactoryInterface $configFactory,
    ) {
        parent::__construct();
    }

    #[Override]
    public function execute(InputInterface $input, OutputInterface $output)
    {
        $this->doExecute($input, $output);
        $io = new DrushStyle($input, $output);
        $io->success("Done");
        return Command::SUCCESS;
    }
    /**
     * Update every Block Visibility Group to fix an issue from migrations.
     */
    public function doExecute(InputInterface $input, OutputInterface $output)
    {
        $io = new DrushStyle($input, $output);
        $blockVisibilityGroups = $this->configFactory->listAll('block_visibility_groups.block_visibility_group.');
        foreach ($blockVisibilityGroups as $blockVisibilityGroup) {
            $io->info(\sprintf("Working on %s", $blockVisibilityGroup));
            $blockVisibilityGroupConfig = $this->configFactory->getEditable($blockVisibilityGroup);
            $blockVisibilityGroupConfig->set('allow_other_conditions', false);
            $blockVisibilityGroupConfig->save();
        }
    }
}
