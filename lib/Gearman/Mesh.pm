package Gearman::Mesh;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Carp qw(croak);
use Gearman::XS 0.16 qw(:constants);
use JSON::XS;

=head1 NAME

Gearman::Mesh - thin wrappers around Gearman::XS modules

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

Gearman::Mesh provides thin wrappers for L<Gearman::XS::Client> and
L<Gearman::XS::Worker>.  The wrappers serialize and deserialize the
data that you pass to workers, and they make it a little easier to
define your workers.  For portability, Gearman::Mesh uses JSON for
data serialization, but it is possible to specify your own serialization
methods.

The Gearman::Mesh module doesn't provide any public methods.  It is a
base class for L<Gearman::Mesh::Client> and L<Gearman::XS::Worker>.

=cut

sub import {
    return unless shift eq 'Gearman::Mesh';
    return unless @_;

    my $pkg = caller;
    return unless $pkg =~ /^Gearman::Mesh::/;

    for my $sub (@_) {
        eval join("\n",
            qq`package $pkg;`,
            qq`sub $sub {shift->{_delegate}->$sub(\@_)}`,
        );
    }
}

sub new {
    my $class    = shift;
    my $delegate = shift;
    my %args     = @_;

    if (not exists $args{serialize_methods}) {
        $args{serialize_methods} ||= [
            \&JSON::XS::encode_json,
            \&JSON::XS::decode_json,
        ];
    }

    my $self = bless {
        _delegate => $delegate->new,
        %args,
    }, $class;

    if (exists $args{servers}) {
        $self->add_servers($args{servers}) == GEARMAN_SUCCESS
            || croak 'Failed to add servers';
    }

    return $self;
}

sub add_servers {
    my $self    = shift;
    my $servers = shift;

    if (ref $servers eq 'ARRAY') {
        $servers = join ',', @$servers;
    }
    elsif (ref $servers eq 'HASH') {
        $servers = join ',', map {$_ . ':' . $servers->{$_}}  keys %$servers;
    }

    $self->{_delegate}->add_servers($servers);
}

sub serialize {
    $_[0]->{serialize_methods}->[0]->($_[1]);
}

sub deserialize {
    $_[0]->{serialize_methods}->[1]->($_[1]);
}

=head1 SEE ALSO

L<< Gearman documentation|http://gearman.info/ >>

L<Gearman::XS> is a Perl front-end for the Gearman C library.  It provides
an almost raw interface to libgearman.  If you want full control over your
Gearman clients, workers, jobs and tasks, this is the module to use.

L<Gearman::Client>, L<Gearman::Task> and L<Gearman::Worker> are pure-Perl APIs
for Gearman.  They provide a simpler interface than L<Gearman::XS>.

L<AnyEvent::Gearman> provides asynchronous Gearman client and worker modules
for L<AnyEvent> applications.

=head1 AUTHOR

Mike Raynham, C<< <enquiries at mikeraynham.co.uk> >>

=head1 REPOSITORY

L<https://github.com/mikeraynham/Gearman-Mesh>

=head1 BUGS

Please report any bugs or feature requests to C<bug-gearman::mesh at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Gearman::Mesh>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Gearman::Mesh


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Gearman::Mesh>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Gearman::Mesh>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Gearman::Mesh>

=item * Search CPAN

L<http://search.cpan.org/dist/Gearman::Mesh/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Mike Raynham, SpareRoom.co.uk.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Gearman::Mesh
