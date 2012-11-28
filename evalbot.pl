#!/usr/bin/perl
use utf8;
use warnings;

use Net::IRC;

my $usage;
$usage="
Run evalbot: ./evalbot.pl configfile

Where configfile is an evalbot config file (see config.sample)
";

if(!$ARGV[0]) { die "$usage"; }
do "$ARGV[0]" or die "Error when doing config file";


if(!$nick)     { die "nick unspecified"; }
if(!$password) { die "password unspecified"; }
if(!$server)   { die "irc server unspecified"; }
if(!$owner)    { die "owner unspecified"; }
if(scalar @channels == 0) { print "No channels specified. Continuing anyways\n"; }

$SIG{'INT'} = 'my_sigint_catcher';
$SIG{'TERM'} = 'my_sigint_catcher';
$SIG{'QUIT'} = 'my_sigint_catcher';
$SIG{'ALRM'} = 'my_alarm';
sub my_sigint_catcher {
   exit(1);
}


# Set up the connection to the IRC server.
my $irc = new Net::IRC;
my $conn = $irc->newconn( Server => "$server",
    Nick => "$nick",
    Ircname => "shbot, owned by $owner, based on evalbot" );


my $joined=0;

sub join_channels {
    foreach (@channels) {
	$conn->join( "$_" );
    }
    $joined=1;
}

sub my_alarm {
    if(!$nickserv) {
	if ($joined==0) {
	    join_channels();
	}
    }
    $conn->privmsg("$nick", "ping");
    alarm(60);
}

alarm(60);

# Connect the handlers to the events.
$conn->add_handler( 376, \&join_channel );
$conn->add_handler( 422, \&join_channel );
$conn->add_handler( 'public', \&message );
$conn->add_handler( 'msg', \&private );
$conn->add_handler( 'notice', \&notice );

# Start the Net::IRC event loop.
$irc->start;

sub join_channel
{
    my( $conn, $event ) = @_;
    print( "Currently online\n" );
}

sub message
{
    my( $conn, $event ) = @_;
    my( $msg ) = $event->args;

    if( $msg =~/^# botsnack$/ ) {
        $conn->privmsg($event->to, "Core dumped.");
    } elsif( $msg =~/^# botsmack$/ ) {
        $conn->privmsg($event->to, "Segmentation fault");
    } elsif( $msg =~/^([^#]*)# (.*)/ ) {
        open(FOO, "-|", "./evalcmd", "$1", "$2");
        while(<FOO>) {
            $conn->privmsg($event->to, $event->nick . ": $_");
        }
        close(FOO);
    }
}

sub private
{
    my( $conn, $event ) = @_;
    my( $msg ) = $event->args;

     if($event->nick =~ /^$nick$/) { return; } #lol

	 $conn->privmsg( "$owner", "< " . $event->nick . "> $msg" );

     if($msg =~ /^!help$/) {
         $conn->privmsg( $event->nick, "Usage: # cmd" );
	 } elsif($msg =~ /^!raw $password (.*)/) {
		 $conn->sl($1);
     } elsif( $msg =~/^([^#]*)# (.*)/ ) {
         open(FOO, "-|", "./evalcmd", "$1", "$2");
         while(<FOO>) {
             $conn->privmsg($event->nick, "$_");
         }
         close(FOO);
     } else {
         open(FOO, "-|", "./evalcmd", "4", "$msg");
         while(<FOO>) {
             $conn->privmsg($event->nick, "$_");
         }
         close(FOO);
     }
}

sub notice
{
    my( $conn, $event ) = @_;
    my( $msg ) = $event->args;
    if ( $event->nick eq "NickServ" ) {
	if($joined==0) {
	    if($nickserv) {
		$conn->privmsg("NickServ", "identify $nickserv");
	    }
	    join_channels();
	}
    }
}


