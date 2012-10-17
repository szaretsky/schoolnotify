package Util::DelayedQueue;

use strict;
use warnings;
use Carp;
use Net::RabbitMQ;
use Redis::Client;

sub CHECK_TIMEOUT { 5 };
sub REDISHOST { 'localhost' };
sub REDISPORT { 6379 }; 
sub QUEUEKEY {'QK'};
sub RABBITMQKEY {'testqueue'};

my $rclient;
my ($mq, $mqc);

sub END {
	$mq->disconnect() if $mq;
	$mqc->disconnect() if $mqc;
}


# Params for queue module
# redishost, redisport, 
sub new {
    	my $class = shift;
    	my $args = shift;
    	my $self = { 	'debug' => 0, 
			'redishost' => REDISHOST(),
			'redisport' => REDISPORT(),
			'redisdelayedkey' => QUEUEKEY(),
			'rabbitqueue' => RABBITMQKEY() 
	};
	if( ref $args ){
		$self->{$_} = $args->{$_} foreach keys %$args;
	}
    	bless($self, $class);

    	return $self;
}

sub _redisconnection {
	my $self = shift;
	unless( ref $rclient ){
		$rclient = Redis::Client->new( host => $self->{'redishost'}, port => $self->{'redisport'} ) || carp "can not connect to Redis server: ".$!;
	}
	return $rclient;
}

sub _rabbitconnection {
	my $self = shift;
	unless( ref $mq ){
		$mq = Net::RabbitMQ->new();
		$mq->connect("localhost", { user => "guest", password => "guest" });
		$mq->channel_open(1);
		$mq->queue_declare(1, $self->{'rabbitqueue'} );
	}
	return $mq;
}


sub _getactual {
	my $self = shift;
	# ..
	my @result = ();
	my $rclient = $self->_redisconnection();
	my $len = $rclient->llen( QUEUEKEY() );
	while($len--){
		my $val = $rclient->lpop( QUEUEKEY() );
		last unless $val;
		my ($msg,$ts) = split(/_/, $val);
		if ($ts<time()) {
			push @result, $msg;
		} else {
			$rclient->rpush(QUEUEKEY(), $val );
		}
	}
	return \@result;
}

# should be called syncroniously to move delayed messages to queue
sub RenewEvents {
	my $self = shift;
	my $to_check = $self->_getactual();
	foreach my $msg( @$to_check ){
		my $res = $self->_rabbitconnection()->publish(1, $self->{'rabbitqueue'}, $msg);
		print "Added to rabbit ".$res if $self->{'debug'};
	};
}

#basically nonblocking get first free
sub GetEvent {
	my $self = shift;
	return $self->_rabbitconnection()->get(1, $self->{'rabbitqueue'} );
} 
		

# Basically add
sub AddEvent { 
	my ( $self, $msg, $timeout ) = @_;
	#...
	my $ts = time() + ( $timeout ? $timeout : CHECK_TIMEOUT() );
	print "Adding to delayed queue ".$msg."_".$ts if $self->{'debug'};
	$self->_redisconnection()->rpush(QUEUEKEY(), $msg."_".$ts);
}
1;
