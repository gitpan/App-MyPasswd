package App::MyPasswd;
use strict;
use warnings;
use Getopt::Long qw/GetOptionsFromArray/;
use IO::Stty;
use Digest::HMAC_SHA1 qw//;

our $VERSION = 0.04;

sub new {
    my $class = shift;
    bless +{}, $class;
}

sub run {
    my $self = shift;
    my @argv = @_;

    my $config = +{};
    _merge_opt($config, @argv);

    _input_master_password($config);

    my $digest = Digest::HMAC_SHA1->new($config->{master_password});
    my $src_hash = $digest->add($config->{salt})->b64digest;

    $src_hash = _filter_hash($src_hash, $config);

    print "use this: $src_hash\n";

    _logging_history($config, @argv) if $config->{log};

    return $src_hash;
}

sub _logging_history {
    my ($config, @argv) = @_;

    require POSIX;
    my $log_time = POSIX::strftime("%Y/%m/%d %H:%M:%S", localtime);
    my $log_line = join ' ', @argv;

    open my $fh, '>>', $config->{log}
        or die "could not open $config->{log}: $!";
    print $fh $log_time. " $log_line\n";
    close $fh;
}

sub _filter_hash {
    my ($src_hash, $config) = @_;

    if ($config->{only_number}) {
        $src_hash = _only_number($src_hash);
    }
    elsif ($config->{only_uc}) {
        $src_hash = _only_case($src_hash, 'uc');
    }
    elsif ($config->{only_lc}) {
        $src_hash = _only_case($src_hash, 'lc');
    }

    if ($config->{no_symbol}) {
        $src_hash = _no_symbol($src_hash);
    }

    $src_hash = substr($src_hash, 0, $config->{length});

    return $src_hash;
}

sub _no_symbol {
    my $src = shift;

    my $result = '';
    for my $str (split '', $src) {
        $str =~ s!^([^a-zA-Z0-9])$!ord($1) % 10!e;
        $result .= $str;
    }

    return $result;
}

sub _only_number {
    my $src = shift;

    my $result = '';
    for my $str (split '', $src) {
        $result .= ($str =~ /^\d+$/) ? $str : ord($str) % 10;
    }

    return $result;
}

sub _only_case {
    my ($src, $case)  = @_;

    my $result = '';
    for my $str (split '', $src) {
        $result .= $case eq 'uc' ? uc $str : lc $str;
    }

    return $result;
}

sub _input_master_password {
    my $config = shift;

    local $SIG{INT} = sub { _stty('echo'); exit; };
    _stty('-echo');

    my ($input, $input_again) = _prompt($config);

    _stty('echo');

    $config->{master_password} = $input;
}

sub _prompt {
    my $config = shift;

    my ($input, $input_again);

_INPUT:
    $input       = _stdin($config, "Input master password:\n");
    $input_again = _stdin($config, "Again, input same master password:\n");

    unless ($input && $input_again) {
        _stty('echo');
        die "[Err] Empty input\n\n";
    }

    if ($input ne $input_again) {
        print "[Err] Your passwords are NOT same. Try to input again.\n\n";
        $input = $input_again = '';
        goto _INPUT;
    }

    return($input, $input_again);
}

sub _stdin {
    my ($config, $msg) = @_;

    print "Input master password:\n";
    my $input = <STDIN>;
    chomp($input);
    print "$input\n" if $config->{show_input};
    return $input;
}

sub _stty {
    my $echo = shift;
    IO::Stty::stty(\*STDIN, $echo);
}

sub _merge_opt {
    my ($config, @argv) = @_;

    Getopt::Long::Configure('bundling');
    GetOptionsFromArray(
        \@argv,
        's|salt=s'    => \$config->{salt},
        'l|length=i'  => \$config->{length},
        'only-number' => \$config->{only_number},
        'only-uc'     => \$config->{only_uc},
        'only-lc'     => \$config->{only_lc},
        'no-symbol'   => \$config->{no_symbol},
        'log=s'       => \$config->{log},
        'show-input'  => \$config->{show_input},
        'h|help'      => sub {
            _show_usage(1);
        },
        'v|version'   => sub {
            print "$0 $VERSION\n";
            exit 1;
        },
    ) or _show_usage(2);

    $config->{salt} = '' unless defined $config->{salt};
    $config->{length} ||= 8;
}

sub _show_usage {
    my $exitval = shift;

    require Pod::Usage;
    Pod::Usage::pod2usage($exitval);
}


1;

__END__

=head1 NAME

App::MyPasswd - generate your password


=head1 SYNOPSIS

    use App::MyPasswd;
    my $mypasswd = App::MyPasswd->new->run(@ARGV);


=head1 DESCRIPTION

See: L<mypasswd> command.


=head1 METHODS

=head2 new

constractor

=head2 run

execute main routine


=head1 REPOSITORY

App::MyPasswd is hosted on github
<http://github.com/bayashi/App-MyPasswd>


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO

This script was inspired from below entry(in Japanese).
<http://d.hatena.ne.jp/kazuhooku/20130509/1368071543>

L<mypasswd>


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
