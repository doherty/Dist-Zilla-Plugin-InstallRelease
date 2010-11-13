use strict;
use warnings;

package Dist::Zilla::Plugin::InstallRelease;
# ABSTRACT: installs your dist after releasing

use Carp ();
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

=cut

has install_command => (
    is      => 'ro',
    isa     => 'Str',
);

=head1 METHODS

=head2 after_release

This gets called after the release is completed - it installs the built dist
using L<CPAN> (unless you specified something different).

=cut

sub after_release {
    my $self = shift;

    eval {
        require File::pushd;
        my $built_in = $self->zilla->built_in;
        ## no critic Punctuation
        my $wd = File::pushd::pushd($built_in);
        my @cmd = $self->{install_command}
                    ? split(/ /, $self->{install_command})
                    : ($^X => '-MCPAN' =>
                            $^O eq 'MSWin32' ? q{-e"install '.'"} : q{-einstall "."});

        $self->log_debug([ 'installing via %s', \@cmd ]);
        system(@cmd) && $self->log_fatal([ 'Error running %s', \@cmd ]);
    };

    if ($@) {
        $self->log($@);
        $self->log('Install failed');
    }
    else {
        $self->log('Installed OK');
    }
    return;
}
no Moose;

1;

__END__
