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

sub new {
    	my $class = shift;
    	my $args = shift;
    	my $self = { 'debug' => 0 };
	if( ref $args ){
		$self->{$_} = $args->{$_} foreach keys %$args;
	}
    	bless($self, $class);
    	return $self;
}

sub _signMessage {
	my ($self, $action, $params) = @_;
	my %paramdata = map { $_=> $params->{$_} } keys %$params;
	$paramdata{'version'} = '3.0';
	$paramdata{'action'} = $action;
	$paramdata{'key'} = PUBLIC_KEY();
	my $stringtoencode = join("", map( $paramdata{$_}, sort { $a cmp $b } keys %paramdata ) );
	$stringtoencode.= PRIVATE_KEY();
	md5_hex( $stringtoencode );
}
	
sub _sendMessage {
	my ($self, $method, $params) = @_;
  	my $ua = LWP::UserAgent->new;
  	$ua->agent("MyApp/0.1 ");
	my $query_string = "key=".PUBLIC_KEY()."&sum=".($self->_signMessage($method, $params))."&".
		join("&",map( $_."=".$params->{$_}, keys %$params ));
	my $req = HTTP::Request->new( GET => SMSGATE_URL().$method."?".$query_string );
	my $result={'result' => { 'id'=>'debug mode on'}};
	if( ! $self->{'debug'} ){ 
		my $res = $ua->request($req);
		if ($res->is_success) {
			my $resp  = $res->content ;
			$result = from_json(  $resp  );
		}
		else {
			carp "Send message error: ". $res->status_line;
		}
	}
	$result;
}

sub GetBalance {
	my $self = shift;
	my $resp = $self->_sendMessage( 'getUserBalance', {'currency' => 'RUB' } );
	return $resp->{'result'}->{'balance_currency'}."\n" if ref $resp;
}

sub SendSMS {
	my ($self, $phone, $msg) = @_;
	my $result = $self->_sendMessage( 'sendSMS', {'sender' => 'School1387', 'text' => $msg, 'phone' => $phone, 'sms_lifetime' => 0});
	if($result->{'error'}){
		return [0, join(" ", map($_."=".$result->{$_}, keys %$result))];
	} else {
		return [1, $result->{'result'}->{'id'}];
	}
}

1;
