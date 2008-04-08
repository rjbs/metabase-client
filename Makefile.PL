require 5.006;
use inc::Module::Install;
name('CPAN-Metabase-Client');
all_from('lib/CPAN/Metabase/Client.pm');

requires('Test::More'   => '0.47');
requires('HTTP::Request::Common' => 0);
requires('LWP::UserAgent'        => 0);

#tests_recursive;
#author_tests('xt');

WriteAll;
