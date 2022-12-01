#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Elf;

sub new {
  my ($class, @food) = @_;

  my $self = {
    food => [ @food ],
    total => 0,
  };

  for my $f (@food) {
    $self->{ total } += $f;
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input01.txt';

my @lines = path( $input_file )->lines( { chomp => 1 } );

# Append a blank line at the end of input file to capture all the elves
push @lines, '';

my $max_cals = 0;
my @food = ();
my @elves;
for my $f (@lines) {
  if ($f) {
    push @food, $f;
   }
  else {
    my $elf = Elf->new( @food );
    if ($elf->{ total } > $max_cals) {
      $max_cals = $elf->{ total };
     }
    push @elves, $elf;
    @food = ();
   }
 }

print "The maximum number of calories is $max_cals\n";

my $top_three = 0;
@elves = sort { $b->{ total } <=> $a->{ total } } @elves;
for my $elf (@elves[0..2]) {
   $top_three += $elf->{ total };
 }

print "The top three elves are carrying $top_three calories\n";

exit;
