use inc::Module::Install;
use 5.008003;

RTx         'RT-Extension-PriorityAsString';
license     'GPLv2';
all_from    'lib/RT/Extension/PriorityAsString.pm';
readme_from 'lib/RT/Extension/PriorityAsString.pm';

requires_rt('RT' => '3.8.3');

no_index('package' => 'RT::Ticket');

WriteAll();
