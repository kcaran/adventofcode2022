#a!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

sub badge {
  my ($elf1, $elf2, $elf3) = @_;

  # Need to use eval for variables inside of tr
  eval "\$elf3 =~ tr/$elf1//cd";
  eval "\$elf3 =~ tr/$elf2//cd";

  return ord( $elf3 ) > 90 ? ord( $elf3 ) - 96 : ord( $elf3 ) - 38;
 }

sub dupes {
  my ($sack) = @_;
  my $half = length( $sack ) / 2;
  my $comp1 = substr( $sack, 0, $half );
  my $comp2 = substr( $sack, $half );

  # Need to use eval for variables inside of tr
  eval "\$comp2 =~ tr/$comp1//cd";

  return ord( $comp2 ) > 90 ? ord( $comp2 ) - 96 : ord( $comp2 ) - 38;
 }

my $input_file = $ARGV[0] || 'input03.txt';
my @lines = path( $input_file )->lines( { chomp => 1 } );
my $sum = 0;

for my $sack (@lines) {
  $sum += dupes( $sack );
 }

print "The total sack dupe priority sum is $sum\n";

$sum = 0;
while (@lines) {
  $sum += badge( splice( @lines, 0, 3 ) );
 }

print "The total badge priority sum is $sum\n";

exit;
