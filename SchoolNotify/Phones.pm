package SchoolNotify::Phones;

use strict;
use warnings;
use Carp;
use Util::DelayedQueue;
use SchoolNotify::SmsApi;

sub new {
    	my $class = shift;
    	my $args = shift;
    	my $self = { 'phonelist' => undef, 'delay' => 1 };
	if( ref $args ){
		$self->{$_} = $args->{$_} foreach keys %$args;
	}
	$self->{'phones'} = [];
	$self->{'sentstorage'} = SchoolNotify::SentStorage->new();
    	bless($self, $class);
    	return $self;
}

sub LoadPhones{
	my $self = shift;
	if( $self->{'phonelist'} ){
		eval{
			open(PHONES, $self->{'phonelist'}) || die ($!);
			while(<PHONES>){
				chomp;
				push @{$self->{'phones'}}, $_;
			}
			close(PHONES);
		};
		if( $@ ){
			carp "Load error ".$@;
			return 0;
		}
		return 1;
	} else {
		carp "No phones file defined";
		return 0;
	}
}

sub SendForList{
	my( $self, $sender, $txt ) = @_;
	foreach my $phone (@{$self->{'phones'}}){
		my $rep = $sender->SendSMS( $phone, $txt );
		$self->{'sentstorage'}->AddSentItem( $rep->[1] );	
		print $phone."\tReport: ".$rep->[1]."\n";
	}
}

1;
