package Dist::Zilla::Plugin::InstallRelease;
use strict;
use warnings;
# ABSTRACT: installs your dist after releasing
# VERSION

use Carp ();
use autodie;
use Moose;
with 'Dist::Zilla::Role::Plugin';
with 'Dist::Zilla::Role::AfterRelease';

=head1 DESCRIPTION

After doing C<dzil release>, this plugin will install your dist so you
are always the first person to have the latest and greatest version. It's
like getting first post, only useful.

To use it, add the following in F<dist.ini>:

    [InstallRelease]

You can specify an alternate install command:

    [InstallRelease]
    install_command = cpanm .

This plugin must always come before L<Dist::Zilla::Plugin::Clean>.

=cut

has install_command => (
    is      => 'ro',
    isa     => 'Str',
    predicate => 'has_install_command',
);

sub after_release {
    my $self = shift;

    eval {
        require File::pushd;
        my $wd = File::pushd::pushd($self->zilla->built_in);
        if ($self->has_install_command) {
            system($self->install_command)
                && $self->log_fatal([ 'error running %s', [$self->install_command] ]);
        }
        else {
            my @cmd = ($^X, '-MCPAN',
                $^O eq 'MSWin32' ? q(-e"install '.'") : q(-einstall '.')
            );
            system(@cmd) && $self->log_fatal([ 'error running %s', \@cmd ]);
        }
    };

    if ($@) {
        $self->log($@);
        $self->log('Install failed.');
    }
    else {
        $self->log('Install OK');
    }

    return;
}

=for Pod::Coverage
after_release
=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;
