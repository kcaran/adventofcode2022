#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

sub add_digit {
  my ($snafu, $digit) = @_;

  if ($digit == 3 || $digit == 4) {
    $digit -= 5;
    my $carry = pop @{ $snafu } || 0;
    $carry = to_dec( $carry ) + 1;
    $snafu = add_digit( $snafu, $carry );
   }
  $digit = ($digit == 0) ? '0' : ($digit == -1) ? '-' : ($digit == -2) ? '=' : $digit;
  push @{ $snafu }, $digit;

  return $snafu;
 }

sub to_snafu {
  my ($dec, $snafu) = @_;

  $snafu = [];

  my $place = 1;
  while ($dec > $place * 5) {
    $place *= 5;
   }
  do {
    my $digit = int( $dec / $place );
    $dec -= $digit * $place;
    $snafu = add_digit( $snafu, $digit );
    $place = int( $place / 5 );
   } while ($place > 0);

  return join( '', @{ $snafu } );
 }

sub to_dec {
  my ($snafu) = @_;

  my $dec = 0;

  my $place = 1;
  for my $digit (reverse split( '', $snafu )) {
    $digit = -2 if ($digit eq '=');
    $digit = -1 if ($digit eq '-');
    $dec += $digit * $place;
    $place *= 5;
   }

  return $dec;
 }

my $input_file = $ARGV[0] || 'input25.txt';

my @lines = path( $input_file )->lines( { chomp => 1 } );
my $sum = 0;
for my $num (@lines) {
  my $dec = to_dec( $num );
  print "$num is $dec\n";
  my $new_num = to_snafu( $dec );
  die "$num doesn't match $new_num" unless ($new_num eq $num);
  $sum += $dec;
 }

my $snafu_sum = to_snafu( $sum );
print "The sum is $sum or $snafu_sum\n";


exit;
