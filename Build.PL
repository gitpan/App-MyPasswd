use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'App::MyPasswd',
    license             => 'perl',
    dist_author         => 'Dai Okabayashi <bayashi@cpan.org>',
    dist_version_from   => 'lib/App/MyPasswd.pm',
    configure_requires  => {
        'Module::Build' => 0.38,
    },
    build_requires      => {
        'Test::More' => 0.88,
        'File::Temp' => 0,
    },
    requires => {
        'perl' => '5.008001',
        'Getopt::Long' => 2.38,
        'IO::Stty' => 0,
        'Digest::HMAC_SHA1' => 0,
        'Pod::Usage' => 0,
        'POSIX' => 0,
    },
    script_files        => [ 'script/mypasswd' ],
    add_to_cleanup      => [ 'App-MyPasswd-*' ],
    meta_merge     => {
      resources => {
        repository  => 'http://github.com/bayashi/App-MyPasswd'
      }
    },
    recursive_test_files => 1,
);

$builder->create_build_script();
