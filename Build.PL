use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new( 
    module_name         => 'ExtUtils::ModuleMaker::TT::DBIx::Class',
    dist_author         => 'Roman F. <romanf@cpan.org>',
    license             => 'perl',
    create_readme       => 1,
    create_makefile_pl  => 'traditional',
    requires            => {
        version => 0.77,
        ExtUtils::ModuleMaker => 0.51,
        ExtUtils::ModuleMaker::TT => 0.93,
        Getopt::Long::Descriptive => 0.086,
        Config::Find => 0.26,
        Config::General => 2.49,
        Path::Class => 0.21,
        Test::DBIx::Class => 0,
    },
    build_requires  => { 
        Test::Simple => 0.44,
    },
)->create_build_script;
