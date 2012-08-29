package SchoolNotify::SmsApi;

use strict;
use warnings;
use Carp;
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use JSON;

sub PUBLIC_KEY() { 'fadc62a97f583ffefa9cafcc2cc969f4' };
sub PRIVATE_KEY() { 'd877aba4b1ff4a924c73515b4451cc4f' };
sub SMSGATE_URL() { 'http://atompark.com/api/sms/3.0/' };

sub _signMessage {
	my ($action, $params) = @_;
	my %paramdata = map { $_=> $params->{$_} } %$params;
	$paramdata{'version'} = '3.0';
	$paramdata{'action'} = $action;
	$paramdata{'key'} = PUBLIC_KEY();
	my $stringtoencode = join("", map( $paramdata{$_}, sort { $a cmp $b } keys %paramdata ) );
	$stringtoencode.= PRIVATE_KEY();
	md5_hex( $stringtoencode );
}
	
sub _sendMessage {
	my ($method, $params) = @_;
  	my $ua = LWP::UserAgent->new;
  	$ua->agent("MyApp/0.1 ");
	my $query_string = "key=".PUBLIC_KEY()."&sum="._signMessage($method, $params)."&".
		join("&",map( $_."=".$params->{$_}, keys %$params ));
	my $req = HTTP::Request->new( GET => SMSGATE_URL().$method."?".$query_string );
	my $res = $ua->request($req);
	my $result;
	if ($res->is_success) {
		my $resp  = $res->content ;
		carp $resp;
      		$result = from_json(  $resp  );
  	}

  	else {
      		print $res->status_line, "\n";
  	}
	$result;
}

sub GetBalance {
	my $resp = _sendMessage( 'getUserBalance', {'currency' => 'RUB' } );
	return $resp->{'result'}->{'balance_currency'}."\n" if ref $resp;
}

sub SendMessage {
	_sendMessage( 'sendSMS', {'sender' => 'Info', 'text' => 'Testing', 'phone' => '79161228520', 'sms_lifetime' => 0});
}

1;
