use strict;
use warnings;
use Test::More;

use App::MyPasswd;

my $mypasswd = App::MyPasswd->new;

{
    my ($password, $output);

    eval {
        ($password, $output) = test_run("");
    };
    like $@, qr/^\[Err\] Empty input/;

    ($password, $output) = test_run("g");
    is $password, 't4U2qI++';

    ($password, $output) = test_run("g", "--length" => 4);
    is $password, 't4U2';

    ($password, $output) = test_run("g", "--salt" => "foo");
    is $password, 'Cf7t23Uw';

    ($password, $output) = test_run("g", "--only-number");
    is $password, '64523333';

    ($password, $output) = test_run("g", "--only-uc");
    is $password, 'T4U2QI++';

    ($password, $output) = test_run("g", "--only-lc");
    is $password, 't4u2qi++';

    ($password, $output) = test_run("g", "--no-symbol");
    is $password, 't4U2qI33';

    ($password, $output) = test_run(
        "g",
        "--salt" => "yakiniku",
        "--length" => 5,
        "--no-symbol",
    );
    is $password, 'bKgid';

}

done_testing;

sub test_run {
    my ($input, @argv)  = @_;

    open my $IN, '<', \"$input\n$input\n";
    local *STDIN = *$IN;

    my $output = '';
    open my $OUT, '>', \$output;
    local *STDOUT = *$OUT;

    note("input:$input, @argv");
    my $password = $mypasswd->run(@argv);

    close $IN;
    close $OUT;

    return($password, $output);
}
