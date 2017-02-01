use strict;
use warnings;

use Test::More;
use IO::Pipe;
use POSIX qw(SIGTERM);
use FindBin qw( $Bin );
use lib ("$Bin/lib", "$Bin/../lib");
use TestGearman;

use Gearman::XS 0.16 qw(:constants);
use Gearman::Mesh::Client;
use Gearman::Mesh::Worker;

my $tg     = TestGearman->new;
my $bucket = IO::Pipe->new;
my $pid    = fork();

die 'Cannot fork' unless defined $pid;

if ($pid == 0) {
    # Child process
    $bucket->writer;
    $bucket->autoflush(1);
    $bucket->blocking(0);

    my $worker = Gearman::Mesh::Worker->new(servers => {$tg->host, $tg->port});

    $worker->add_function(
        append => sub {
            my ($job, $args, $workload) = @_;
            $bucket->print($workload);
        },
    );

    $worker->work_loop;

    exit;
}
else {
    # Parent process
    $bucket->reader;

    my $client = Gearman::Mesh::Client->new(servers => {$tg->host, $tg->port});

    for my $num (1..5) {
        $client->do(append => $num);
    }

    kill SIGTERM, $pid;
    waitpid($pid, 0);

    my $result = <$bucket>;
    is($result, '12345', 'work_loop processed multiple jobs');

    done_testing;
}
