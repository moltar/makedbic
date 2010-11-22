# ExtUtils::ModuleMaker::TT::DBIx::Class - check module loading and create testing directory

use Test::More tests =>  2 ;

BEGIN { use_ok( 'ExtUtils::ModuleMaker::TT::DBIx::Class' ); }

my $object = ExtUtils::ModuleMaker::TT::DBIx::Class->new ();
isa_ok ($object, 'ExtUtils::ModuleMaker::TT::DBIx::Class');
