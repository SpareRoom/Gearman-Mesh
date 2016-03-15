use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Gearman::Mesh',
    license             => 'artistic_2',
    dist_author         => q{Mike Raynham, SpareRoom <enquiries@mikeraynham.co.uk>},
    dist_version_from   => 'lib/Gearman/Mesh.pm',
    release_status      => 'unstable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Gearman::XS' => 0.16,
        'JSON::XS'    => 0,
        'Sub::Name'   => 0,
    },
    add_to_cleanup     => [ 'Gearman-Mesh-*' ],
    create_makefile_pl => 'traditional',
    meta_merge => {
        resources => {
            repository => 'https://github.com/mikeraynham/Gearman-Mesh',
        }
    },
);

$builder->create_build_script();
