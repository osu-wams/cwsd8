<?php

namespace Drush\Commands;

use Drupal\Core\Config\ConfigFactoryInterface;
use Drush\Commands\AutowireTrait;
use Drush\Style\DrushStyle;
use Override;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: self::NAME,
    description: 'Update the CAS Settings that are wrong.'
)]
final class UpdateCasSettingsCommand extends Command
{
    use AutowireTrait;

    public const string NAME = 'osu:cas-settings-update';

    public function __construct(
        private readonly ConfigFactoryInterface $configFactory,
    ) {
        return parent::__construct();
    }

    #[Override]
    public function execute(InputInterface $input, OutputInterface $output): int
    {
        $this->doExecute($input, $output);
        $io = new DrushStyle($input, $output);
        $io->success('Updated CAS Settings.');
        return Command::SUCCESS;
    }

    /**
     * Update CAS Settings that are missing.
     *
     * @param InputInterface $input
     * @param OutputInterface $output
     * @return void
     */
    public function doExecute(InputInterface $input, OutputInterface $output): void
    {
        $casSettings = $this->configFactory->getEditable('cas.settings');
        $casGateWaySettings = $casSettings->get('gateway');
        $casGateWaySettings['recheck_time'] = 720;
        $casGateWaySettings['method'] = 'client_side';
        $casGateWaySettings['enabled'] = false;
        unset($casGateWaySettings['check_frequency']);
        $casSettings->set('gateway', $casGateWaySettings);
        $casUserSettings = $casSettings->get('user_accounts');
        $casUserSettings['auto_register_follow_registration_policy'] = false;
        $casSettings->set('user_accounts', $casUserSettings);
        $casSettings->save();
    }
}
