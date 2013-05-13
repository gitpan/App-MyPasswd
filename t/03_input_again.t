use strict;
use warnings;
use Test::More;

use App::MyPasswd;

my $mypasswd = App::MyPasswd->new;

{
    open my $IN, '<', \"a\nb\na\na\n";
    local *STDIN = *$IN;

    my $output = '';
    open my $OUT, '>', \$output;
    local *STDOUT = *$OUT;

    my $password = $mypasswd->run;

    close $IN;
    close $OUT;

    is $password, 'DVLIgmxk';
    like $output, qr/\Q[Err] Your passwords are NOT same. Try to input again./;
}

done_testing;
