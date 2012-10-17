#!/usr/bin/perl -w


use warnings;
use Data::Dumper;
use lib qw(/home/me/schoolnotify);
use SchoolNotify::SmsApi;
use SchoolNotify::Phones;
use SchoolNotify::SentStorage;
use Getopt::Long;

my $ds = SchoolNotify::SentStorage->new(); 

while(1){
	my $eventtocheck = $ds->GetItemToCheck();
	print Data::Dumper::Dumper( $eventtocheck );
	sleep(1);
}	

#$ds->AddSentItem(17); while(1){ my $data = $ds->GetActual(); print Data::Dumper::Dumper( $data); sleep 1};

