use strict;
use warnings;
use Test::More;

use App::MyPasswd;

{
    my $mypasswd = App::MyPasswd->new;
    is ref($mypasswd), 'App::MyPasswd', 'new';
}

done_testing;
