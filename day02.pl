#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my $scoring = {
   'A X' => { score => 4, play => 'A Z' },
   'B X' => { score => 1, play => 'B X' },
   'C X' => { score => 7, play => 'C Y' },
   'B Y' => { score => 5, play => 'B Y' },
   'C Y' => { score => 2, play => 'C Z' },
   'A Y' => { score => 8, play => 'A X' },
   'C Z' => { score => 6, play => 'C X' },
   'A Z' => { score => 3, play => 'A Y' },
   'B Z' => { score => 9, play => 'B Z' },
  };

sub score {
  my ($round) = @_;

  return $scoring->{ $round }{ score };
 }

sub play {
  my ($round) = @_;

  return score( $scoring->{ $round }{ play } );
 }

my $input_file = $ARGV[0] || 'input02.txt';

my @lines = path( $input_file )->lines( { chomp => 1 } );
my $score = 0;

for my $round (@lines) {
  $score += score( $round );
 }

print "The total score for part 1 is $score\n";

$score = 0;
for my $round (@lines) {
  $score += play( $round );
 }

print "The total score for part 2 is $score\n";

exit;
