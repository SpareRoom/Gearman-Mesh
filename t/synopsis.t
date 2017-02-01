use strict;
use warnings;

use Test::More;
use FindBin qw( $Bin );
use lib ("$Bin/lib", "$Bin/../lib");
use TestGearman;

use Gearman::Mesh::Client qw(:constants);
use Gearman::Mesh::Worker;

my $tg     = TestGearman->new;
my $worker = Gearman::Mesh::Worker->new(servers => {$tg->host, $tg->port});
my $client = Gearman::Mesh::Client->new(servers => {$tg->host, $tg->port});

my @result;

$worker->add_function(reverse => sub {
    my $job      = shift;
    my $args     = shift;
    my $workload = shift;

    @result = map {scalar reverse} @$workload;
});

$client->add_options(GEARMAN_CLIENT_NON_BLOCKING);
$client->do(reverse => [qw(foo bar baz)]);

$worker->work;

is_deeply(\@result, [qw(oof rab zab)], 'all strings reversed');

done_testing;
