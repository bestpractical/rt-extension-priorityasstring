use inc::Module::Install;
use 5.008003;

RTx         'RT-Extension-PriorityAsString';
license     'GPLv2';
all_from    'lib/RT/Extension/PriorityAsString.pm';

requires('RT' => '3.8.3');

WriteAll();
