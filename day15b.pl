#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

my $max;

use Path::Tiny;

{ package Sensor;

use List::Util qw( max min );

 sub y_intersect {
   my ($self, $y) = @_;

   my $intersect = $self->{ radius } - abs($y - $self->{ pos }[0]);

   return if ($intersect < 0);
   return [ max( min( $self->{ pos }[1] - $intersect, $max ), 0 ), max( min( $self->{ pos }[1] + $intersect, $max ), 0) ];
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
    pos => [],
    beacon => [],
  };
  bless $self, $class;

  $input =~ /^Sensor at x=([-0-9]+), y=([-0-9]+): closest beacon is at x=([-0-9]+), y=([-0-9]+)/;
  $self->{ pos } = [$2, $1];
  $self->{ beacon } = [$4, $3];
  $self->{ radius } = abs($2 - $4) + abs($1 - $3);

  return $self;
 }
}

my @sensors;
my $input_file = $ARGV[0] || 'input15.txt';
$max = $ARGV[1] || 4000000;
for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
   my $sensor = Sensor->new( $line );
   push @sensors, $sensor;
  }

my $debug = 0;
my $found;
my $y = 0;
while (!$found && $y < $max) {
  my @cannot = sort { $a->[0] <=> $b->[0] || $b->[1] <=> $a->[1] } map { $_->y_intersect( $y ) || () } @sensors;
  my $r = shift @cannot;
  my $pos = ($r->[1] - $r->[0] + 1);
  my $min = $r->[1] + 1;
  print join( ', ', @{ $r }), "\n" if ($debug);
  for $r (@cannot) {
    print join( ', ', @{ $r }), "\n" if ($debug);
    next unless ($r->[1] >= $min);

    # Look for the disconnect!
    if ($r->[0] > $min) {
      $found = [ $y, $min ];
     }

    $min = ($r->[0] > $min) ? $r->[0] : $min;
    $pos += ($r->[1] - $min + 1);
    $min = $r->[1] + 1;
   }
  print "There are $pos positions unavailable for $y\n" if ($debug);
  $y++;
 }

print "The tuning frequency is ", $found->[0] + $found->[1] * 4000000, "\n";
exit;
