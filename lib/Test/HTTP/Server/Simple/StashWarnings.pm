#!/usr/bin/env perl
package Test::HTTP::Server::Simple::StashWarnings;
use strict;
use warnings;
use base 'Test::HTTP::Server::Simple';

use 5.008;

use NEXT;
use Storable ();

sub test_warning_path {
    my $self = shift;
    die "You must override test_warning_path in $self to tell " . __PACKAGE__ . " where to provide test warnings.";
}

sub background {
    my $self = shift;

    local $SIG{__WARN__} = sub {
        push @{ $self->{'thss_stashed_warnings'} }, @_;
        warn @_ if $ENV{TEST_VERBOSE};
    };

    return $self->NEXT::background(@_);
}

sub handler {
    my $self = shift;

    if ($self->{thss_test_path_hit}) {
        my @warnings = splice @{ $self->{'thss_stashed_warnings'} };
        my $content  = Storable::nfreeze(\@warnings);

        print "HTTP/1.0 200 OK\r\n";
        print "Content-Type: application/x-perl\r\n";
        print "Content-Length: ", length($content), "\r\n";
        print "\r\n";
        print $content;

        return;
    }

    return $self->NEXT::handler(@_);
}

sub setup {
    my $self = shift;
    my @copy = @_;

    while (my ($item, $value) = splice @copy, 0, 2) {
        if ($item eq 'request_uri') {
            $self->{thss_test_path_hit} = $value eq $self->test_warning_path;
        }
    }

    return $self->NEXT::setup(@_);
}

sub decode_warnings {
    my $self = shift;
    my $text = shift;

    return @{ Storable::thaw($text) };
}

sub DESTROY {
    my $self = shift;
    for (@{ $self->{'thss_stashed_warnings'} }) {
        warn "Unhandled warning: $_";
    }
}

1;

__END__

=head1 NAME

Test::HTTP::Server::Simple::StashWarnings - catch your forked server's warnings

=head1 COPYRIGHT & LICENSE

Copyright 2007-2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

