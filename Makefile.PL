use inc::Module::Install;

# Define metadata
name           'makedbic';
author         'Roman F. <romanf@cpan.org>';
version        '0.1.2';
license        'perl';
perl_version   '5.008';

# Specific dependencies
requires       'version' => '0.77',
requires       'ExtUtils::ModuleMaker' => '0.51',
requires       'ExtUtils::ModuleMaker::TT' => '0.93',
requires       'Getopt::Long::Descriptive' => '0.086',
requires       'Config::Find' => '0.26',
requires       'Config::General' => '2.49',
requires       'Path::Class' => '0.21',
requires       'Test::DBIx::Class' => 0,
test_requires  'Test::More'  => '0.42';
install_script 'scripts/makedbic';

auto_install();

WriteAll;