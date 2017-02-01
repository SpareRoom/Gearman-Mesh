package TestGearman;

use strict;
use warnings;

use Test::TCP ();
use File::Which ();
use Proc::Guard ();

sub new {
    my $class    = shift;
    my $gearmand = File::Which::which('gearmand');

    my %args = (
        'port'     => Test::TCP::empty_port(),
        'listen'   => '0.0.0.0',
        'log-file' => 'none',
    );

    my @args = map { sprintf('--%s=%s', $_, $args{$_}) } keys %args;
    my $proc = Proc::Guard->new(command => [ $gearmand, @args ]);

    Test::TCP::wait_port($args{port});

    return bless {
        host  => $args{listen},
        port  => $args{port},
        _proc => $proc
    }, $class;
}

sub host {$_[0]->{host}}
sub port {$_[0]->{port}}

1;
