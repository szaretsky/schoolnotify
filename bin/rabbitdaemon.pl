#!/usr/bin/perl -w


use warnings;
use Data::Dumper;
use lib qw(/home/me/schoolnotify);
use SchoolNotify::SmsApi;
use SchoolNotify::Phones;
use Util::DelayedQueue;
use Getopt::Long;

my $ds = Util::DelayedQueue->new({'debug' => 1}); 

while(1){
	my $eventtocheck = $ds->RenewEvents();
	sleep(1);
}	


