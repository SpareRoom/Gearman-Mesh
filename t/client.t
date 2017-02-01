use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Gearman::Mesh::Client qw(:constants);

subtest 'add servers' => sub {

    is( exception {
            Gearman::Mesh::Client->new(
                servers => '127.0.0.1:4730,127.0.0.2:4730',
            ),
        },
        undef,
        'client constructor can add a string of servers'
    );

    is( exception {
            Gearman::Mesh::Client->new(
                servers => [
                    '127.0.0.1:4730',
                    '127.0.0.2:4730',
                ],
            ),
        },
        undef,
        'client constructor can add an array of servers'
    );

    is( exception {
            Gearman::Mesh::Client->new(
                servers => {
                    '127.0.0.1' => 4730,
                    '127.0.0.2' => 4730,
                },
            ),
        },
        undef,
        'client constructor can add a hash of servers'
    );


};

my $client = Gearman::Mesh::Client->new;

can_ok($client, qw(
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
    add_servers

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
));

is( $client->add_server('127.0.0.1', 4730),
    GEARMAN_SUCCESS,
    'client can add server'
);

$client->remove_servers;

is( $client->do_background(reverse => 'gnirts'),
    undef,
    'client returns nothing when job fails'
);

done_testing;
