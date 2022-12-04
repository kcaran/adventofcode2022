#a!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my $input_file = $ARGV[0] || 'input04.txt';
my @lines = path( $input_file )->lines( { chomp => 1 } );

my $dupes = 0;
my $overlaps = 0;
for my $pair (@lines) {
  my ($p1l, $p1h, $p2l, $p2h) = ($pair =~ /^(\d+)-(\d+),(\d+)-(\d+)$/);
  my $dupe = (($p2l >= $p1l) && ($p2h <= $p1h))
		  || (($p1l >= $p2l) && ($p1h <= $p2h)) ? 1 : 0;
  $dupes += $dupe;
  my $overlap = 
		   (($p1l <= $p2l) && ($p2l <= $p1h))
		|| (($p1l <= $p2h) && ($p2h <= $p1h))
		|| (($p2l <= $p1l) && ($p1l <= $p2h))
		|| (($p2l <= $p1h) && ($p1h <= $p2h)) ? 1 : 0;
  $overlaps += $overlap;
 }

print "The total number of dupes is $dupes\n";
print "The total number of overlaps is $overlaps\n";

exit;
