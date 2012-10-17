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
$phones->SendForList($sender, 'Уважаемые родители! Сегодня в 18:00 в актовом зале встреча с директором. Родительский комитет 1Г.');


my $balance = $sender->GetBalance();
print "Balance ".$balance."\n";
