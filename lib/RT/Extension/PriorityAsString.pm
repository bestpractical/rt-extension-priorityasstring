use 5.008003;
use strict;
use warnings;

package RT::Extension::PriorityAsString;

our $VERSION = '0.04';

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

    # Uncomment if you want to apply different configurations to
    # different queues.  Each key is the name of a different queue;
    # queues which do not appear in this configuration will use RT's
    # default numeric scale.
    # Set(%PriorityAsStringQueues,
    #    General => { Low => 0, Medium => 50, High => 100 },
    #    Binary  => { Low => 0, High => 10 },
    # );

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

# Returns String: Various Ticket Priorities as either a string or integer
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

    my %map;
    my $queues = RT->Config->Get('PriorityAsStringQueues');
    if (@_) {
        %map = %{ shift(@_) };
    } elsif ($queues and $queues->{$self->QueueObj->Name}) {
        %map = %{ $queues->{$self->QueueObj->Name} };
    } else {
        %map = RT->Config->Get('PriorityAsStringQueues');
    }
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
