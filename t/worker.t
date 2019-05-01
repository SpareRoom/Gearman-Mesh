use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Gearman::Mesh::Worker qw(:constants);

subtest 'add servers' => sub {

    is( exception {
            Gearman::Mesh::Worker->new(
                servers => '127.0.0.1:4730,127.0.0.2:4730',
            ),
        },
        undef,
        'client constructor can add a string of servers'
    );

    is( exception {
            Gearman::Mesh::Worker->new(
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
            Gearman::Mesh::Worker->new(
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

my $worker = Gearman::Mesh::Worker->new;

can_ok($worker, qw(
    add_function
    add_servers

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
));

is( $worker->add_server('127.0.0.1', 4730),
    GEARMAN_SUCCESS,
    'worker can add server'
);

$worker->remove_servers;

is( $worker->work(),
    GEARMAN_NO_SERVERS,
    'work() method returns expected value'
);

my ($ret, $job) = $worker->grab_job();

is( $ret,
    GEARMAN_NO_SERVERS,
    'grab_job() method returns expected value...'
);

is( $job,
    undef,
    '...and it does not return a job'
);

done_testing;
