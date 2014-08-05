#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 3;

BEGIN {
    use_ok( 'Gearman::Mesh' ) || print "Bail out!\n";
    use_ok( 'Gearman::Mesh::Client' ) || print "Bail out!\n";
    use_ok( 'Gearman::Mesh::Worker' ) || print "Bail out!\n";
}

diag( "Testing Gearman::Mesh $Gearman::Mesh::VERSION, Perl $], $^X" );
