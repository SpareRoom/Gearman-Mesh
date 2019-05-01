package Gearman::Mesh::Client;

use 5.006;
use strict;
use warnings FATAL => 'all';

use parent 'Gearman::Mesh';

use Gearman::Mesh qw(
    add_server
    remove_servers
    options
    set_options
    add_options
    remove_options
    timeout
    set_timeout
    echo
    run_tasks
    set_created_fn
    set_data_fn
    set_complete_fn
    set_fail_fn
    set_status_fn
    set_warning_fn
    error
    do_status
    job_status
    wait
    clear_fn
);

use Exporter 5.57 qw(import);
use Gearman::XS 0.16 qw(:constants);

our @EXPORT_OK   = @Gearman::XS::EXPORT_OK;
our %EXPORT_TAGS = %Gearman::XS::EXPORT_TAGS;

BEGIN {
    my @jobs = qw(
        do
        do_high
        do_low
        do_background
        do_high_background
        do_low_background
        add_task
        add_task_high
        add_task_low
        add_task_background
        add_task_high_background
        add_task_low_background
    );

    my $pkg = __PACKAGE__;

    for my $job (@jobs) {
        
        eval join("\n",
            qq`package $pkg;`,
             q`require Carp;`,
            qq`sub $job {`,
             q`    my $self     = shift;`,
             q`    my $task     = shift;`,
             q`    my $workload = shift;`,
             q`    my $unique   = shift;`,
            qq`    my \@ret = \$self->{_delegate}->$job(`,
             q`        $task,`,
             q`        $self->serialize([$workload]),`,
             q`        defined $unique ? $unique : (),`,
             q`    );`,
             q`    return if !defined $ret[0];`,
             q`    return if $ret[0] ne GEARMAN_SUCCESS;`,
             q`    return $ret[1];`,
             q`}`,
        );
    }
}

=head1 NAME

Gearman::Mesh::Client - A wrapper around Gearman::XS::Client

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';


=head1 SYNOPSIS

 use Gearman::Mesh::Client;

 my $client = Gearman::Mesh::Client->new(servers => [
     'gearman1:4730',
     'gearman2:4730',
 ]);

 $client->do_background(reverse => [qw(foo bar baz)]);

=head1 CONSTANTS

This module optionally re-exports the constants from L<Gearman::XS>:

 use Gearman::Mesh::Client qw(:constants);

=head1 CONSTRUCTOR

=head2 new

 my $worker = Gearman::Mesh::Worker(
    servers           => $servers?,
    serialize_methods => \@serialize_methods,
 );

=cut

sub new {
    shift->SUPER::new('Gearman::XS::Client', @_);
}

=head1 METHODS

=head2 do, do_high, do_low
=head2 do_background, do_high_background, do_low_background
=head2 add_task, add_task_high, add_task_low
=head2 add_task_background, add_task_high_background, add_task_low_background

 my $job_handle = $client->do($function_name => $workload, $unique?);
 my $task = $client->add_task($function_name => $workload, $unique?);

Each of these methods are wrapped in a method that serializes C<$workload>
before calling the equivalent L<Gearman::XS::Client> method.

Each method will retry up to ten times, using an exponential backoff algorithm
to determine the delay between retries.

Job methods (those whose names begin with C<do>) will return the job handle on
success.  Task methods (those whose name begin with C<add_task>) will return a
L<Gearman::XS::Task> object on success.  On failure, the methods will return
nothing.

The optional C<$unique> parameter is a string that uniquely identifies the job.
It is used by gearmand to coalesce jobs: if multiple clients request a job with
the same unique identifier, gearmand will perform the job only once and return
the result to all the clients that requested it.  Please note that this only
works for jobs that are in the same queue at the same time.

=head2 add_server, remove_servers, options, set_options, add_options
=head2 remove_options, timeout, set_timeout, echo, run_tasks, set_created_fn
=head2 set_data_fn, set_complete_fn, set_fail_fn, set_status_fn
=head2 set_warning_fn, error, do_status, job_status, wait, clear_fn

These methods pass the call through to a delegate L<Gearman::XS::Worker>
object.


=cut

=head1 AUTHOR

Mike Raynham, C<< <enquiries at mikeraynham.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-gearman::mesh at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Gearman::Mesh>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Gearman::Mesh::Client


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

1; # End of Gearman::Mesh::Client
