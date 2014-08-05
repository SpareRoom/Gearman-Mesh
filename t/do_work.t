use strict;
use warnings;

use Test::More;

use Gearman::XS qw(:constants);
use Gearman::Mesh::Client;
use Gearman::Mesh::Worker;

my $worker = Gearman::Mesh::Worker->new;

$worker->add_server('localhost', 4730);

if ($worker->echo('ping') != GEARMAN_SUCCESS) {
    plan(skip_all => 'gearmand must be running on localhost to run this test');
}

my $client = Gearman::Mesh::Client->new;

$client->add_server('localhost', 4730);
$client->add_options(GEARMAN_CLIENT_NON_BLOCKING);

# Make sure that we correctly serialize and deserialize Unicode strings,
# and strings that contain null characters.
my $test_args = {
    arg1 => "\x{2699}\x{1F468}\x{0}\x{0}\x{3BCC}",
    arg2 => "\x{3BCC}\x{0}\x{0}\x{2699}\x{1F468}",
};

my $result = 0;
my $add = 1;

$worker->add_function(
    func1 => sub {
        my $job      = shift;
        my $args     = shift;
        my $workload = shift;

        $result += $workload->{add};

        is_deeply(
            $args,
            $test_args,
            'args deserialized and passed to job'
        );
    },
    $test_args,
);

my @test_functions = qw(
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

for my $function (@test_functions) {
    $client->$function(func1 => {add => $add});
    $add = $add << 1;
}

$client->run_tasks();

$worker->work for (1..12);

is($result, 4095, 'result is 4095');

done_testing;
