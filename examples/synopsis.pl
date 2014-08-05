#!perl

use strict;
use warnings;

use Gearman::Mesh::Client qw(:constants);
use Gearman::Mesh::Worker;

{
    my $client = Gearman::Mesh::Client->new;

    $client->add_server('localhost', 4730);

    my $job_handle = $client->do_background(add => [1, 2, 4, 8]);
}

{
    my $worker = Gearman::Mesh::Worker->new;
    my $result;

    $worker->add_server('localhost', 4730);

    $worker->add_function(
        add => sub {
            my ($job, $args, $workload) = @_;

            $result += $_ for @$workload;
        }
    );

    $worker->work;
    print "$result\n";

}
