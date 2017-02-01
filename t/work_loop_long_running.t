use strict;
use warnings;

use Test::More;
use IO::Pipe;
use POSIX qw(SIGTERM);

use Gearman::XS 0.16 qw(:constants);
use Gearman::Mesh::Client;
use Gearman::Mesh::Worker;

{
    my $worker = Gearman::Mesh::Worker->new(servers => '127.0.0.1:4730');
    $worker->set_timeout(1000);

    plan(skip_all => 'gearmand must be running on 127.0.0.1 to run this test')
        if $worker->echo('ping') != GEARMAN_SUCCESS;
}

my $bucket = IO::Pipe->new;
my $pid    = fork();

die 'Cannot fork' unless defined $pid;

if ($pid == 0) {
    # Child process
    $bucket->writer;
    $bucket->autoflush(1);
    $bucket->blocking(0);

    my $worker = Gearman::Mesh::Worker->new(servers => {'127.0.0.1' => 4730});

    $worker->add_function(
        long_running => sub {
            my (undef, undef, $workload) = @_;
            for my $i (1..5) {
                $bucket->print($i);
                sleep 1;
            }
        },
    );

    $worker->add_function(
        worker_ready => sub {
            my ($job) = @_;
            $job->send_complete(1);
        },
    );

    $worker->work_loop;

    exit;
}
else {
    # Parent process
    $bucket->reader;

    my $client = Gearman::Mesh::Client->new(servers => {'127.0.0.1' => 4730});

    ok($client->do('worker_ready'), 'worker is ready');

    $client->do_background('long_running');

    kill SIGTERM, $pid;
    waitpid($pid, 0);

    my $result = <$bucket>;
    is($result, '12345', 'work_loop processed long-running job');

    done_testing;
}
