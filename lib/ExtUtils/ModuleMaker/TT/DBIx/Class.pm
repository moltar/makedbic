package ExtUtils::ModuleMaker::TT::DBIx::Class;

use strict;
use warnings;
use Carp;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    use version 0.77; our $VERSION = version->declare('v0.1.1');
    @ISA         = qw(Exporter);
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

# Parents need to be specified in reverse order, because
# ExtUtils::ModuleMaker unshift's them into @ISA
use parent qw/ExtUtils::ModuleMaker::TT ExtUtils::ModuleMaker::StandardText/;

use Path::Class;

#--------------------------------------------------------------------------#
# main pod documentation 
#--------------------------------------------------------------------------#

=head1 NAME

ExtUtils::ModuleMaker::TT::DBIx::Class - Makes skeleton modules for
DBIx::Class schemas with Template Toolkit templates.

=head1 SYNOPSIS

 makedbic -s My::App::Schema -r Artist,CD,Track --base --resultsets

=head1 DESCRIPTION

This module extends L<ExtUtils::ModuleMaker::TT> to create skeleton schema
classes for L<DBIx::Class>. Just like the ExtUtils::ModuleMaker::TT it uses
L<Template Toolkit 2|Template> templates. Templates may either be default
templates supplied within the module or user-customized templates in a directory
specified.

Notable changes from ExtUtils::ModuleMaker::TT:

=over 4

=item *

Default option for I<TEST_NAME_DERIVED_FROM_MODULE_NAME> is set to true.

=item *

Default option for I<INCLUDE_SCRIPTS_DIRECTORY> is set to false.

=item *

Default option for I<VERBOSE> is set to true.

=back

=head1 USAGE

This module holds most subclass logic, however you most likely want to use the
command line utility that does most of the work.

Please look at the L<makedbic> docs if all you want to do is create new schemas.

=cut

sub process_template {
    my ($self, $template, $data) = @_;

    if ($template =~ m{\.(t|pm)$}) {
        my ($filename, $ext) = split(/\./, $template);
        my $module_type_name = sprintf('%s_%s.%s', $filename, $data->{DBIC_MODULE_TYPE}, $ext);
        if (exists $ExtUtils::ModuleMaker::TT::templates{$module_type_name}
            || (-d $self->{'TEMPLATE_DIR'} && -e file($self->{'TEMPLATE_DIR'}, $module_type_name))) {
            $template = $module_type_name;
        }
    }

    return $self->SUPER::process_template($template, { %{$self}, %{$data} });
}

sub print_file {
    my ($self, $filename, $filetext) = @_;

    # inject one more file before we sign out
    if ($filename eq 'MANIFEST') {
        $self->create_directory(dir($self->{Base_Dir}, 't/etc'));
        $self->print_file('t/etc/schema.pl', $self->text_schema_config());
    }
    
    return $self->SUPER::print_file($filename, $filetext);
}

sub text_schema_config {
    my $self = shift;
    return $self->process_template('schema.pl', $self);
}

sub build_single_column {
    my ($self, $column_name) = @_;
    return $self->process_template('column',
        { %{$self}, column_name => $column_name });
}

sub create_template_directory {
    my $self = shift;
    
    # remove unused templates that were inherited
    for ('module.pm', 'method') {
        delete $ExtUtils::ModuleMaker::TT::templates{$_};
    }
    
    return $self->SUPER::create_template_directory(@_);
}

my $MODULE_HEADER = <<'EOF';
[%- IF NEED_POD %]
#--------------------------------------------------------------------------#
# main pod documentation 
#--------------------------------------------------------------------------#

# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

[% NAME %] - Put abstract here 

=head1 SYNOPSIS

 use [% NAME %];
 blah blah blah

=head1 DESCRIPTION

Description...

=head1 USAGE

Usage...

=cut
[%- END -%]
EOF

my $MODULE_FOOTER = <<'EOF';
1; # this line is important and will help the module return a true value

__END__
[% IF NEED_POD %]
[%- IF CHANGES_IN_POD -%]
=head1 HISTORY
[% END %]
=head1 SEE ALSO

L<DBIx::Class>

=head1 AUTHOR

[% AUTHOR %] [% IF CPANID %]([% CPANID %])[% END %]
[%- IF ORGANIZATION %]

[% ORGANIZATION %]
[%- END %]

[% EMAIL %]

[% WEBSITE %]

=head1 COPYRIGHT

Copyright (c) [% COPYRIGHT_YEAR %] by [% AUTHOR %]

[%  LicenseParts.COPYRIGHT %]

=cut
[%- END -%]
EOF

#-------------------------------------------------------------------------#

$ExtUtils::ModuleMaker::TT::templates{'module_main.pm'} = <<"EOF";
package [% NAME %];
use strict;
use warnings;

our $VERSION = 0.001000;

use base qw/DBIx::Class::Schema/;

$MODULE_HEADER

__PACKAGE__->load_namespaces;

$MODULE_FOOTER
EOF

#-------------------------------------------------------------------------#

$ExtUtils::ModuleMaker::TT::templates{'module_result.pm'} = <<"EOF";
package [% NAME %];
use strict;
use warnings;

use base qw/[% DBIC_BASE %]/;

$MODULE_HEADER

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('[% NAME.split('::').last | lower %]');
__PACKAGE__->add_columns(

);
__PACKAGE__->set_primary_key('');

$MODULE_FOOTER
EOF

#-------------------------------------------------------------------------#

$ExtUtils::ModuleMaker::TT::templates{'module_resultset.pm'} = <<"EOF";
package [% NAME %];
use strict;
use warnings;

$MODULE_HEADER

use base qw/[% DBIC_BASE %]/;

$MODULE_FOOTER
EOF

#-------------------------------------------------------------------------#

$ExtUtils::ModuleMaker::TT::templates{'module_base_result.pm'} = <<"EOF";
package [% NAME %];
use strict;
use warnings;

$MODULE_HEADER

use base qw/DBIx::Class::Core/;

$MODULE_FOOTER
EOF

#-------------------------------------------------------------------------#

$ExtUtils::ModuleMaker::TT::templates{'module_base_resultset.pm'} = <<"EOF";
package [% NAME %];
use strict;
use warnings;

$MODULE_HEADER

use base qw/DBIx::Class::ResultSet/;

$MODULE_FOOTER
EOF

#-------------------------------------------------------------------------#
    
$ExtUtils::ModuleMaker::TT::templates{'Build.PL'} = <<'EOF';
use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new( 
    module_name         => '[% NAME %]',
    dist_author         => '[% AUTHOR %] <[% EMAIL %]>',
[%- IF LICENSE.match('perl|gpl|artistic') %]
    license             => '[% LICENSE %]',
[%- END %]
    create_readme       => 1,
    create_makefile_pl  => 'traditional',
    requires            => {
        'DBIx::Class' => 0,
    },
    build_requires      => {
        'Test::More' => 0,
        'Test::DBIx::Class' => 0,
    },
)->create_build_script;
EOF

#-------------------------------------------------------------------------#

$ExtUtils::ModuleMaker::TT::templates{'Makefile.PL'} = <<'EOF';
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    NAME         => '[% NAME %]',
    VERSION_FROM => '[% FILE %]', # finds $VERSION
    AUTHOR       => '[% AUTHOR %] ([% EMAIL %])',
    ABSTRACT     => '[% ABSTRACT %]',
    PREREQ_PM    => {
        'DBIx::Class' => 0,
        'Test::More' => 0,
        'Test::DBIx::Class' => 0,
    },
);
EOF

#-------------------------------------------------------------------------#
    
$ExtUtils::ModuleMaker::TT::templates{'test.t'} = <<'EOF';
# [% NAME %]

use strict;
use warnings;

use Test::More;
use Test::DBIx::Class qw(:resultsets);

done_testing;
EOF

#-------------------------------------------------------------------------#
    
$ExtUtils::ModuleMaker::TT::templates{'test_result.t'} = <<'EOF';
# [% NAME %]

use strict;
use warnings;

use Test::More;
use Test::DBIx::Class qw(:resultsets);

fixtures_ok 'basic' => 'installed the basic fixtures from configuration files';

done_testing;
EOF

#-------------------------------------------------------------------------#
    
$ExtUtils::ModuleMaker::TT::templates{'schema.pl'} = <<'EOF';
{
    'schema_class' => '[% NAME %]',
    'connect_info' => ['dbi:SQLite:dbname=:memory:', '', ''],
    'resultsets'   => [
[% FOREACH class IN DBIC_RESULTS_CLASSES -%]
        '[% class %]',
[% END -%]
    ],
    'fixture_sets' => {
        'basic' => {
[% FOREACH class IN DBIC_RESULTS_CLASSES -%]
            '[% class %]' => [
                [qw//],
                [],
            ],
[% END -%]
        },
    },
};
EOF

#-------------------------------------------------------------------------#
    
$ExtUtils::ModuleMaker::TT::templates{'column'} = <<'EOF';
[% IF NEED_POD -%]
=head2 [% column_name %]()

 $rv = $object->[% column_name %]();

Description of [% column_name %]...

=cut
[% END -%]
'[% column_name %]' => {
    data_type	    => '',
    is_nullable	    => 1,
    is_numeric      => 0,
    default_value   => '',
},

EOF

1;
__END__

=head1 BUGS

Please report bugs using the CPAN Request Tracker at L<http://rt.cpan.org/>

=head1 AUTHOR

Roman F. (ROMANF)

romanf@cpan.org

=head1 COPYRIGHT

Copyright (c) 2010 by Roman F.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut