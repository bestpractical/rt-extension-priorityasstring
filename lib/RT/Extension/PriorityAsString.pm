use 5.008003;
use strict;
use warnings;

package RT::Extension::PriorityAsString;

our $VERSION = '0.03';

=head1 NAME

RT::Extension::PriorityAsString - show priorities in RT as strings instead of numbers

=head1 SYNOPSIS

    # in RT config
    Set(@Plugins, qw(... RT::Extension::PriorityAsString ...));

    # Specify a mapping between priority strings and the internal
    # numeric representation
    Set(%PriorityAsString, (Low => 0, Medium => 50, High => 100));

    # which order to display the priority strings
    # if you don't specify this, the strings in the PriorityAsString
    # hash will be sorted and displayed
    Set(@PriorityAsStringOrder, qw(Low Medium High));

=head1 INSTALLATION

*NOTE* that it only works with RT 3.8.3 and newer.

    perl Makefile.PL
    make
    make install (may need root permissions)

    Edit your /opt/rt3/etc/RT_SiteConfig.pm (example is in synopsis above)

    rm -rf /opt/rt3/var/mason_data/obj
    Restart your webserver

=cut

require RT::Ticket;
package RT::Ticket;

=head2 PriorityAsString

Returns String: Various Ticket Priorities as either a string or integer

=cut

sub PriorityAsString {
    my $self = shift;
    return $self->_PriorityAsString($self->Priority);
}

sub InitialPriorityAsString {
    my $self = shift;
    return $self->_PriorityAsString( $self->InitialPriority );
}

sub FinalPriorityAsString {
    my $self=shift;
    return $self->_PriorityAsString( $self->FinalPriority );
}

sub _PriorityAsString {
    my $self = shift;
    my $priority = shift;
    return undef unless defined $priority && length $priority;

    my %map = RT->Config->Get('PriorityAsString');
    if ( my ($res) = grep $map{$_} == $priority, keys %map ) {
        return $res;
    }

    my @order = reverse grep defined && length, RT->Config->Get('PriorityAsStringOrder');
    @order = sort { $map{$b} <=> $map{$a} } keys %map
        unless @order;

    # XXX: not supported yet
    #my $show  = RT->Config->Get('PriorityAsStringShow') || 'string';

    foreach my $label ( @order ) {
        return $label if $priority >= $map{ $label };
    }
    return "unknown";
}

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2008, Best Practical Solutions LLC.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ruslan Zakirov E<lt>ruz@bestpractical.comE<gt>

=cut

1;
