#!/usr/bin/perl -w

use warnings;
use Data::Dumper;
use lib qw(/home/me/schoolnotify);
use SchoolNotify::SmsApi;
use SchoolNotify::Phones;
use Getopt::Long;

my $debug = 0;
my $phonelist = '/home/devel/schoolnotify/phones.txt';

GetOptions( 'debug' => \$debug , 'phones=s' => \$phonelist );

my $sender = new SchoolNotify::SmsApi({ 'debug' => $debug});
my $phones = new SchoolNotify::Phones({ 'phonelist' => $phonelist });
$phones->LoadPhones();
$phones->SendForList($sender, '3 сентября детей ждут в школе в 8:15. С собой нужен рюкзак, пенал и сменка. Родительский комитет 1Г.');


my $balance = $sender->GetBalance();
print "Balance ".$balance."\n";
