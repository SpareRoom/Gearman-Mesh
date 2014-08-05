package Gearman::Mesh::Worker;

use 5.006;
use strict;
use warnings FATAL => 'all';

use parent 'Gearman::Mesh';

use Gearman::Mesh qw(
    add_server
    remove_servers
    echo
    work
    grab_job
    error
    options
    set_options
    add_options
    remove_options
    timeout
    set_timeout
    register
    unregister
    unregister_all
    function_exist
    wait
    set_log_fn
);

use Exporter 5.57 qw(import);
use Gearman::XS qw(:constants);

our @EXPORT_OK   = @Gearman::XS::EXPORT_OK;
our %EXPORT_TAGS = %Gearman::XS::EXPORT_TAGS;

=head1 NAME

Gearman::Mesh::Worker - The great new Gearman::Mesh::Worker!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

 use Gearman::Mesh::Worker qw(:constants);

 my $worker = Gearman::Mesh::Worker->new(servers => 'localhost:4730');

 $worker->add_function(reverse => sub {
     my $job      = shift;
     my $args     = shift;
     my $workload = shift;

     @result = map {scalar reverse} @$workload;
 });

 $worker->work;

=head1 CONSTANTS

This module optionally re-exports the constants from L<Gearman::XS>:

 use Gearman::Mesh::Worker qw(:constants);

=head1 CONSTRUCTOR

=head2 new

 my $worker = Gearman::Mesh::Worker(
    servers           => $servers?,
    serialize_methods => \@serialize_methods,
 );

=cut

sub new {
    shift->SUPER::new('Gearman::XS::Worker', @_);
}

=head1 SUBROUTINES/METHODS

=head2 add_function

 add_function(
    $name => $coderef,
    $args,
    $timeout,
 );

=cut

sub add_function {
    my $self    = shift;
    my $name    = shift;
    my $coderef = shift;
    my $args    = shift;
    my $timeout = shift || 0;

    my $serialized_args = $self->serialize([$args]);

    $self->{_delegate}->add_function(
        $name,
        $timeout,
        sub {
            my $_job      = shift;
            my $_args     = shift;
            my $_workload = $_job->workload;

            ($_args)     = @{$self->deserialize($_args)};
            ($_workload) = @{$self->deserialize($_workload)};

            @_ = ($_job, $_args, $_workload);

            goto $coderef;
        },
        $serialized_args,
    );
}

=head2 add_server, remove_servers, echo, work, grab_job, error, options
=head2 set_options, add_options, remove_options, timeout, set_timeout
=head2 register, unregister, unregister_all, function_exist, wait, set_log_fn

These methods pass the call through to a delegate L<Gearman::XS::Worker>
object.

=head1 AUTHOR

Mike Raynham, C<< <enquiries at mikeraynham.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-gearman::mesh at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Gearman::Mesh>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Gearman::Mesh::Worker


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

Copyright 2014 Mike Raynham.

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

1; # End of Gearman::Mesh::Worker
