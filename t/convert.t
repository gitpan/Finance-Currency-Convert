#!/usr/bin/perl -w
use strict;
use Test;
BEGIN {plan tests => 5};

use Finance::Currency::Convert;

# test object creation
my $converter = new Finance::Currency::Convert;
ok($converter);

# test conversion to self
my $amount0 = $converter->convert(456, "EUR", "EUR");
ok($amount0, 456);

# test build in exchange rate
my $amount1 = $converter->convert(1, "EUR", "DEM");
ok($amount1, 1.95583);

# test convertFromEUR
my $amount2 = $converter->convert(1, "EUR", "DEM");
my $amount3 = $converter->convertFromEUR(1, "DEM");
ok($amount2, $amount3);

# test convertToEUR
my $amount4 = $converter->convert(1, "DEM", "EUR");
my $amount5 = $converter->convertToEUR(1, "DEM");
ok($amount4, $amount5);


