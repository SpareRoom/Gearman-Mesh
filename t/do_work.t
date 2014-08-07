use strict;
use warnings;

use Test::More;
use File::Temp qw(tempfile);

use Gearman::XS 0.16 qw(:constants);
use Gearman::Mesh::Client;
use Gearman::Mesh::Worker;

my ($fh, $tmp_file) = tempfile();

my $pid = fork();

die 'Cannot fork' unless defined $pid;

if ($pid == 0) {
    # Child process

    # Make sure that we correctly serialize and deserialize Unicode strings,
    # and strings that contain null characters.
    my $test_args = {
        arg1 => "\x{2699}\x{1F468}\x{0}\x{0}\x{3BCC}",
        arg2 => "\x{3BCC}\x{0}\x{0}\x{2699}\x{1F468}",
    };
    
    my $worker = Gearman::Mesh::Worker->new(servers => {localhost => 4730});

    $worker->add_function(
        'sum', sub {
            my $job      = shift;
            my $args     = shift;
            my $workload = shift;

            open my $out, '>>', $tmp_file or die "Cannot open file: $!";
            print $out "$workload\n";
            close $out;

            is_deeply(
                $args,
                $test_args,
                "($workload) args deserialized and passed to job"
            );

            $job->send_complete($workload);
        },
        $test_args,
    );

    $worker->add_function(
        'no_args', sub {
            my $job      = shift;
            my $args     = shift;
            my $workload = shift;

            is($args, '', '$args is empty');
            is($workload, undef, '$workload is not defined');

            $job->send_complete(123);
        },
    );

    # Set non-blocking mode so that the child process can exit when there
    # are no more jobs to process.
    $worker->add_options(GEARMAN_WORKER_NON_BLOCKING);
    $worker->set_timeout(300);

    my $no_jobs = 0;

    while (1) {
        my $ret = $worker->work;

        $no_jobs = 0, next if $ret == GEARMAN_SUCCESS;
        $no_jobs++         if $ret == GEARMAN_NO_JOBS;

        $worker->wait;

        last if $no_jobs >= 3;
    }

    done_testing;
    exit;
}
else {

    my $client = Gearman::Mesh::Client->new(servers => {localhost => 4730});
    my $num    = 1;

    subtest 'synchronous jobs' => sub {

        # do, do_high and do_low run synchronously.

        my $result = 0;

        for my $function (qw(do do_high do_low)) {
            $result += $client->$function(sum => $num);
            $num = $num << 1;
        }

        is($result, 7, 'foreground job results correct');
        is($client->do('no_args'), 123, 'job with no args runs as expected');
    };

    subtest 'asynchronous jobs' => sub {
        my @asynchronous = qw(
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

        for my $function (@asynchronous) {
            $client->$function(sum => $num);
            $num = $num << 1;
        }

        $client->run_tasks();

        waitpid $pid, 0;

        my $result;

        for (<$fh>) {
            chomp;
            $result += $_;
        }
        close $fh;

        is($result, 4095, 'final result is correct');
    };

    done_testing;
}
