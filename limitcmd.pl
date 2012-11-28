#!/usr/bin/perl

my @signals = qw< HUP INT QUIT TERM SEGV PIPE XCPU XFSZ ALRM >;
my $signal = 'TERM';



sub signal_handler($) {
    my ($sig) = @_;
    kill $signal, $child;
    exit 255;
}

$child = fork;
if($child == 0) {
    exec "./runqemu", $ARGV[0], $ARGV[1] or die "internal error :(";
}

foreach my $sig (@signals) {
    $SIG{$sig} = \&signal_handler;
}

alarm 4;
while (($pid = wait) != -1 && $pid != $child) {}
exit $?
#exit ($pid == $child_pid ? 0 : 1);




