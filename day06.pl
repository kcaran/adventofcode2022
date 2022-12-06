#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

sub test_start {
  my ($str) = @_;

  my %found;
  for my $c (split( '', $str )) {
    $found{ $c }++;
    return 0 if ($found{ $c } > 1);
   }

  return 1;
 }

my $input_text = $ARGV[0] || path( 'input06.txt' )->slurp_utf8( { chomp => 1 } );

my $found = 0;
my $index = 4;
while (!$found) {
  $index++ unless ($found = test_start(substr( $input_text, $index - 4, 4 )));
 }

print "The first marker is after character $index\n";

$found = 0;
$index = 14;
while (!$found) {
  $index++ unless ($found = test_start(substr( $input_text, $index - 14, 14 )));
 }

print "The first message is after character $index\n";

exit;
