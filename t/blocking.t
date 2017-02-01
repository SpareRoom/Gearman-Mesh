use strict;
use warnings;

use Test::More;
use POSIX qw(SIGTERM);
use FindBin qw( $Bin );
use lib ("$Bin/lib", "$Bin/../lib");
use TestGearman;

use Gearman::XS 0.16 qw(:constants);
use Gearman::Mesh::Client;
use Gearman::Mesh::Worker;

my $tg     = TestGearman->new;
my $pid    = fork();

die 'Cannot fork' unless defined $pid;

if ($pid == 0) {
    # Child process
    my $worker = Gearman::Mesh::Worker->new(servers => {$tg->host, $tg->port});

    $worker->add_function(
        block => sub {
            my ($job) = @_;
            sleep 2;
            $job->send_complete(1);
        },
    );

    $worker->work;

    exit;
}
else {
    # Parent process
    my $client = Gearman::Mesh::Client->new(servers => {$tg->host, $tg->port});

    ok($client->do('block'), 'do blocks');

    waitpid($pid, 0);

    done_testing;
}
