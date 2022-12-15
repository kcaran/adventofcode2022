#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use day13;

sub compare {
  my ($p0, $p1) = @_;

  my $compare = 0;
  while ($compare == 0) {
    if (!ref($p0)) {
     if (!ref($p1)) {
       return 1 if (!defined( $p0 ));
       return -1 if (!defined( $p1 ));
       return ($p1 <=> $p0);
      }
     else {
       $p0 = Packet->new( $p0 );
       return compare( $p0, $p1 );
      }
     }
    else {
      if (!ref($p1)) {
        $p1 = Packet->new( $p1 );
        return compare( $p0, $p1 );
       }
      return 1 if (@{ $p0->{ vals } } == 0 && @{ $p1->{ vals } } != 0);
      return -1 if (@{ $p1->{ vals } } == 0 && @{ $p0->{ vals } } != 0);
      return 0 if (@{ $p1->{ vals } } == 0 && @{ $p0->{ vals } } == 0);
     }
    $compare = compare( shift @{ $p0->{ vals } }, shift @{ $p1->{ vals } } );
   }

  return $compare;
 }

my $input_file = $ARGV[0] || 'input13.txt';

my @lines = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );
my $index = 1;
my $sum = 0;
while (@lines) {
  my ($packet0, $packet1) = splice( @lines, 0, 2 );

  my $p0 = Packet->new( $packet0 );
  my $p1 = Packet->new( $packet1 );

  my $compare = compare( $p0, $p1 );
  print "$index $packet0\n" if ($compare > 0);
  $sum += $index if ($compare > 0);

  # Empty line
  shift @lines;
  $index++;
 }

print "The sum of the correct-ordered indices is ", $sum, "\n";

exit;
