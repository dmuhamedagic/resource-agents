#!/usr/bin/perl

###############################################################################
###############################################################################
##
##  Copyright (C) Sistina Software, Inc.  1997-2003  All rights reserved.
##  Copyright (C) 2004 Red Hat, Inc.  All rights reserved.
##  
##  This copyrighted material is made available to anyone wishing to use,
##  modify, copy, or redistribute it subject to the terms and conditions
##  of the GNU General Public License v.2.
##
###############################################################################
###############################################################################

use Getopt::Std;
use Net::Telnet ();

# Get the program name from $0 and strip directory names
$_=$0;
s/.*\///;
my $pname = $_;

$opt_o = 'hardreset';           # Default fence action.  

my $logged_in = 0;

# WARNING!! Do not add code bewteen "#BEGIN_VERSION_GENERATION" and 
# "#END_VERSION_GENERATION"  It is generated by the Makefile

#BEGIN_VERSION_GENERATION
$FENCE_RELEASE_NAME="v6.0.0";
$SISTINA_COPYRIGHT=("Copyright (C) Red Hat, Inc.  2004  All rights reserved.");
$BUILD_DATE="(built Thu Nov 18 14:06:47 EST 2004)";
#END_VERSION_GENERATION

sub usage 
{
	print "Usage:\n";
	print "\n";
	print "$pname [options]\n";
	print "\n";
	print "Options:\n";
	print "  -a <ip>          IP address DRAC\n";
	print "  -h               usage\n";
	print "  -l <name>        Login name\n";
	print "  -o <string>      Action: hardreset(default), powerdown, powerup, powercycle \n";
	print "  -p <string>      Login password\n";
	print "  -q               quiet mode\n";
	print "  -V               version\n";
	
	exit 0;
}

sub fail
{
	($msg)=@_;
	print $msg."\n" unless defined $opt_q;

	exit 1;
}

sub fail_usage
{
	($msg)=@_;
	print STDERR $msg."\n" if $msg;
	print STDERR "Please use '-h' for usage.\n";
	exit 1;
}

sub version
{
	print "$pname $FENCE_RELEASE_NAME $BUILD_DATE\n";
	print "$SISTINA_COPYRIGHT\n" if ( $SISTINA_COPYRIGHT );
	exit 0;
}


sub get_options_stdin
{
	my $opt;
	my $line = 0;
	while( defined($in = <>) )
	{
		$_ = $in;
		chomp;

		# strip leading and trailing whitespace
		s/^\s*//;
		s/\s*$//;

		# skip comments
		next if /^#/;
	
		$line+=1;
		$opt=$_;
		next unless $opt;

		($name,$val)=split /\s*=\s*/, $opt;

		if ( $name eq "" )
		{
			print STDERR "parse error: illegal name in option $line\n";
			exit 2;
		} 
		# DO NOTHING -- this field is used by fenced 
		elsif ($name eq "agent" ) 
		{
		} 
		elsif ($name eq "ipaddr" ) 
		{
			$opt_a = $val;
		} 
		elsif ($name eq "login" ) 
		{
			$opt_l = $val;
		} 
		elsif ($name eq "option" ) 
		{
			$opt_o = $val;
		} 
		elsif ($name eq "passwd" ) 
		{
			$opt_p = $val;
		} 
		# Excess name/vals will fail
		else 
		{
			fail "parse error: unknown option \"$opt\"";
		}
	}
}
		

### MAIN #######################################################

if (@ARGV > 0) {
	getopts("a:hl:o:p:V") || fail_usage ;
	
	usage if defined $opt_h;
	version if defined $opt_V;

	fail_usage "Unkown parameter." if (@ARGV > 0);

	fail_usage "No '-a' flag specified." unless defined $opt_a;
	fail_usage "No '-l' flag specified." unless defined $opt_l;
	fail_usage "No '-p' flag specified." unless defined $opt_p;
	fail_usage "Unrecognised action '$opt_o' for '-o' flag"
		unless $opt_o =~ /^(hardreset|powerdown|powerup|powercycle)$/i;

} else {
	get_options_stdin();

	fail "failed: no IP address" unless defined $opt_a;
	fail "failed: no login name" unless defined $opt_l;
	fail "failed: no password" unless defined $opt_p;
	fail "failed: unrecognised action: $opt_o"
		unless $opt_o =~ /^(hardreset|powerdown|powerup|powercycle)$/i;
} 

exec("racadm -r $opt_a -u $opt_l -p $opt_p serveraction $opt_o");
fail("exec error: $!\n");
exit 1;


