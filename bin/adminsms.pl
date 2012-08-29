#!/usr/bin/perl -w

use warnings;
use Data::Dumper;
use lib qw(/home/me/schoolnotify);
use SchoolNotify::SmsApi;

my $balance = SchoolNotify::SmsApi::GetBalance() ;

print $balance->{'result'}->{'balance_currency'}."\n";

SchoolNotify::SmsApi::SendMessage();
