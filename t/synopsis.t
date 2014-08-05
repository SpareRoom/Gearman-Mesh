use strict;
use warnings;

use Test::More;

use Gearman::Mesh::Client qw(:constants);
use Gearman::Mesh::Worker;

my $client = Gearman::Mesh::Client->new(servers => 'localhost:4730');
my $worker = Gearman::Mesh::Worker->new(servers => 'localhost:4730');

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
