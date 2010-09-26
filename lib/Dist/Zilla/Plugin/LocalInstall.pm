use strict;
use warnings;

package Dist::Zilla::Plugin::LocalInstall;
# ABSTRACT: installs your dist after releasing

use Carp ();
use Moose;
with 'Dist::Zilla::Role::AfterRelease';

=head1 DESCRIPTION

After doing C<dzil release>, this plugin will install your dist so you
are always the first person to have the latest and greatest version. It's
like getting first post, only useful.

=head1 METHODS

=head2 after_release

This gets called after the release is completed - it installs the built dist
using L<CPAN>.

=cut

sub after_release {
    my $self = shift;
    my $built_in = $self->zilla->built_in;

    eval {
        require File::pushd;
        ## no critic Punctuation
        my $wd = File::pushd::pushd($built_in);
        my @cmd = ($^X => '-MCPAN' =>
                $^O eq 'MSWin32' ? q{-e"install '.'"} : '-einstall "."');

        $self->log_debug([ 'installing via %s', \@cmd ]);
        system(@cmd) && $self->log_fatal([ "error running %s", \@cmd ]);
    };

    if ($@) {
        $self->log($@);
        $self->log("install failed");
    }
    else {
        $self->log("install OK");
    }
    return;
}

no Moose;

1;

__END__
