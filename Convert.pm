#!/usr/bin/perl -w
#
#	Copyright (C) 2000, Jan Willamowius <jan@willamowius.de>
#	All rights reserved.
#	This is free software; you can redistribute it and/or
#	modify it under the same terms as Perl itself.
#

package Finance::Currency::Convert;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
$VERSION = '0.01';

my %EuroRates = (
	ATS  => {ATS => 1, BEF => 2.930215, DEM => 0.14207, ESP => 12.08612, EUR => 0.0726727, FIM => 0.431892, FRF => 0.476476, GRD => 24.72058, IEP => 0.0572349, ITL => 140.6481, LUF => 2.929862, NLG => 0.160074, PTE => 14.56289}, 
	BEF  => {ATS => 0.341109, BEF => 1, DEM => 0.048484, ESP => 4.124601, EUR => 0.024789, FIM => 0.147391, FRF => 0.162608, GRD => 8.432342, IEP => 0.019523, ITL => 47.998878, LUF => 1, NLG => 0.054628, PTE => 4.969819}, 
	DEM  => {ATS => 7.03553, BEF => 20.625463, DEM => 1, ESP => 85.071808, EUR => 0.511292, FIM => 3.040004, FRF => 3.353855, GRD => 173.9191, IEP => 0.402675, ITL => 989.999146, LUF => 20.625463, NLG => 1.126739, PTE => 102.504822}, 
	ESP  => {ATS => 0.082701, BEF => 0.242448, DEM => 0.011755, ESP => 1, EUR => 0.00601, FIM => 0.035735, FRF => 0.039424, GRD => 2.044426, IEP => 0.004733, ITL => 11.637217, LUF => 0.242448, NLG => 0.013245, PTE => 1.204921}, 
	EUR  => {ATS => 13.7603, BEF => 40.339901, DEM => 1.95583, ESP => 166.386002, EUR => 1, FIM => 5.94573, FRF => 6.55957, GRD => 340.3229, IEP => 0.787564, ITL => 1936.27002, LUF => 40.339901, NLG => 2.20371, PTE => 200.481995}, 
	FIM  => {ATS => 2.314316, BEF => 6.784684, DEM => 0.328947, ESP => 27.984116, EUR => 0.168188, FIM => 1, FRF => 1.10324, GRD => 57.21161, IEP => 0.132459, ITL => 325.657227, LUF => 6.784684, NLG => 0.370637, PTE => 33.718651}, 
	FRF  => {ATS => 2.097744, BEF => 6.149778, DEM => 0.298164, ESP => 25.365381, EUR => 0.152449, FIM => 0.906421, FRF => 1, GRD => 51.85781, IEP => 0.120063, ITL => 295.182465, LUF => 6.149778, NLG => 0.335953, PTE => 30.563284}, 
	GRD  => {ATS => 0.0404049, BEF => 0.118444, DEM => 0.00574301, ESP => 0.488571, EUR => 0.00293756, FIM => 0.0174586, FRF => 0.019261, GRD => 1, IEP => 0.0023137, ITL => 5.68554, LUF => 0.118436, NLG => 0.00647076, PTE => 0.588681}, 
	IEP  => {ATS => 17.471977, BEF => 51.221107, DEM => 2.483392, ESP => 211.266647, EUR => 1.269738, FIM => 7.54952, FRF => 8.328936, GRD => 431.9145, IEP => 1, ITL => 2458.555664, LUF => 51.221107, NLG => 2.798135, PTE => 254.559631}, 
	ITL  => {ATS => 0.007107, BEF => 0.020834, DEM => 0.00101, ESP => 0.085931, EUR => 0.000516, FIM => 0.003071, FRF => 0.003388, GRD => 0.17568, IEP => 0.000407, ITL => 1, LUF => 0.020834, NLG => 0.001138, PTE => 0.10354}, 
	LUF  => {ATS => 0.341109, BEF => 1, DEM => 0.048484, ESP => 4.124601, EUR => 0.024789, FIM => 0.147391, FRF => 0.162608, GRD => 8.425906, IEP => 0.019523, ITL => 47.998878, LUF => 1, NLG => 0.054628, PTE => 4.969819}, 
	NLG  => {ATS => 6.244152, BEF => 18.305449, DEM => 0.887517, ESP => 75.502678, EUR => 0.45378, FIM => 2.698055, FRF => 2.976603, GRD => 154.361, IEP => 0.357381, ITL => 878.640991, LUF => 18.305449, NLG => 1, PTE => 90.974762}, 
	PTE  => {ATS => 0.068636, BEF => 0.201215, DEM => 0.009756, ESP => 0.82993, EUR => 0.004988, FIM => 0.029657, FRF => 0.032719, GRD => 1.696712, IEP => 0.003928, ITL => 9.658074, LUF => 0.201215, NLG => 0.010992, PTE  => 1}
				);
sub new() {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	$self->{CurrencyRates} = \%EuroRates;
	$self->{RatesFile} = undef;
	$self->{UserAgent} = "Finance::Currency::Convert $VERSION";
	bless($self, $class);
	return $self;
}

sub setRate() {
	my $self = shift;
	my $source = shift;
	my $target = shift;
	my $rate = shift;
	$self->{CurrencyRates}{$source}{$target} = $rate;
}

sub setRatesFile() {
	my $self = shift;
	$self->{RatesFile} = shift;
	$self->readRatesFile();
}

sub readRatesFile() {
	my $self = shift;
	return if (!defined $self->{RatesFile});

	open(RATES, "<$self->{RatesFile}") or return;
	$self->{CurrencyRates} = (); # clear current table
	while(<RATES>) {
		my ($source, $targetrates) = split(/\|/, $_);
		foreach my $target (split(/\:/, $targetrates)) {
			my @pieces = split(/\=/, $target);
			if (scalar(@pieces) > 1) {
				$self->setRate($source, $pieces[0], $pieces[1]);
			}
		}
	}
	close(RATES);
}

sub writeRatesFile() {
	my $self = shift;
	return if (!defined $self->{RatesFile});

	open(RATES, ">$self->{RatesFile}") or return;
	foreach my $sourcerate (sort keys %{$self->{CurrencyRates}}) {
		print RATES "$sourcerate|";
		foreach my $targetrate (sort keys %{ $self->{CurrencyRates}{$sourcerate}}) {
			print RATES "$targetrate=" . $self->{CurrencyRates}{$sourcerate}{$targetrate} . ":";
		};
		print RATES "\n";
	};
	close(RATES);
}

sub updateRates() {
	my $self = shift;
	my @CurrencyList = @_;
	# Test if Finance::Quote is available
	eval { require Finance::Quote; };
	if ($@) { return; };	# F::Q not installed
	# get the exchange rates
	my $q = Finance::Quote->new;
	$q->user_agent->agent($self->{UserAgent});
	foreach my $source (@CurrencyList) {
		foreach my $target (sort keys %{ $self->{CurrencyRates}}) {
print "update $source -> $target\n";
#			$self->setRate($source, $target, $q->currency($source, $target));
		}
	}
	foreach my $source (sort keys %{ $self->{CurrencyRates}}) {
		foreach my $target (@CurrencyList) {
print "update $source -> $target\n";
#			$self->setRate($source, $target, $q->currency($source, $target));
		}
	}
}

sub setUserAgent() {
	my $self = shift;
	$self->{UserAgent} = shift;
}

sub convert() {
	my $self = shift;
	my $amount = shift;
	my $source = shift;
	my $target = shift;
	return $amount * $self->{CurrencyRates}->{$source}{$target};
}

sub convertFromEUR() {
	my $self = shift;
	my $amount = shift;
	my $target = shift;
	return $self->convert($amount, "EUR", $target);
}

sub convertToEUR() {
	my $self = shift;
	my $amount = shift;
	my $source = shift;
	return $self->convert($amount, $source, "EUR");
}

1;

__END__

=pod

=head1 NAME

Finance::Currency::Convert -
Convert currencies and fetch their exchange rates (with Finance::Quote)

=head1 SYNOPSIS

   use Finance::Currency::Convert;
   my $converter = new Finance::Currency::Convert;

   $amount_euro = $converter->convert(100, "DEM", "EUR");
   $amount_euro = $converter->convertToEuro(100, "DEM");
   $amount_dem = $converter->convertFromEuro(100, "DEM");

   $converter->updateRates("EUR", "DEM", "USD");

   $converter->setRatesFile(".rates");
   $converter->writeRatesFile();


=head1 DESCRIPTION

This module converts currencies. It has built in the fixed exchange
rates for all Euro currencies (as of November 2000). If you wish to use other / more
currencies, you can automatically fetch their exchange rates from
the internet and (optionally) store them in a file for later reference.

Use this module if you have large volumes of currency data to convert.
Using the exchange rates from memory makes it a lot faster than
using Finance::Quote directly and will save you the duty of storing
the exchange rates yourself.

=head2 CURRENCY SYMBOLS

Finance::Currency::Convert uses the three character ISO currency codes
used by  Finance::Quote.
Here is a list of currency codes.

Currencies with built-in rates (complete):

	EUR		Euro
	ATS		Austrian Schilling
	BEF		Belgiam Franc
	DEM		German Mark
	ESP		Spanish Peseta
	FIM		Finnish Mark
	FRF		French Franc
	GRD		Greek Drachma
	IEP		Irish Punt
	ITL		Italian Lira
	LUF		Luxembourg Franc
	NLG		Dutch Guilder
	PTE		Portuguese Escudo

Other currencies (incomplete):

	AUD		Australian Dollar
	USD		US Dollar

=head1 AVAILABLE METHODS

=head2 NEW

   my $converter = new Finance::Currency::Convert;

The newly created conversion object will by default only know how to
convert Euro currencies. To "teach" it more currencies use updateRates.

=head2 CONVERT

   $amount_euro = $converter->convert(100, "DEM", "EUR");

This will convert 100 German Marks into the equivalent
amount Euro.

=head2 CONVERTTOEURO

   $amount_euro = $converter->convertToEuro(100, "DEM");

This will convert 100 German Marks into the equivalent amount Euro.
This function is simply shorthand for calling convert directly with
"EUR" als the second (target) currency.

=head2 CONVERTFROMEURO

   $amount_dem = $converter->convertFromEuro(100, "DEM");

This will convert 100 Eurointo the equivalent amount German Marks.
This function is simply shorthand for calling convert directly with
"EUR" als the first (source) currency.

=head2 UPDATERATES

   $converter->updateRates("USD");
   $converter->updateRates("EUR", "DEM", "USD");

This will fetch the exchange rates for one or more currencies using
Finance::Quote and update the exchange rates in memory.
This method will fetach all combinations of exchange rates between
the named currencies and the ones already in memory.
This may result in a large number of requests to Finance::Quote.
To avoid network overhead you can store the retrieved rates with
setRatesFile() / writeRatesFile() once you have retrieved them
and load them again with setRatesFile().

=head2 SETUSERAGENT

	$converter->setUserAgent("MyCurrencyAgent 1.0");

Set the user agent string to be used by Finance::Quote.

=head2 SETRATE

	$converter->setRate("EUR", "USD", 999);

Set one exchange rate. Used internally by updateRates,
but may be of use if you have to add a rate manually.

=head2 SETRATESFILE

   $converter->setRatesFile(".rates");

Name the file where exchange rates are stored. If it already exists
it will be read into memory.

=head2 READRATESFILE

   $converter->readRatesFile();

Usually called internally by setRatesFile, but may also be called
directly to revert to the rates stored in the file.
Calling readRatesFile() will erase all existing exchange rates in memory.

=head2 WRITERATESFILE

   $converter->writeRatesFile();

Call this function to save table with exchange rates from memory
to the file named by setRatesFile() eg. after fetching new rates
with updateRates.

=head1 AUTHOR

  Jan Willamowius <jan@willamowius.de>, http://www.willamowius.de

=head1 SEE ALSO

Finance::Quote

This module is only needed for fetching exchange rates.
There is no need to install it when only Euro currencies are used.

=cut

