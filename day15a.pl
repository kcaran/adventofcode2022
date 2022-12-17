#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Sensor;

 sub y_intersect {
   my ($self, $y) = @_;

   my $intersect = $self->{ radius } - abs($y - $self->{ pos }[0]);

   return if ($intersect < 0);
   return [ $self->{ pos }[1] - $intersect, $self->{ pos }[1] + $intersect];
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

my @ranges;
my @sensors;
my $input_file = $ARGV[0] || 'input15.txt';
my $y_line = $ARGV[1] || 2000000;
my $pos = 0;
my %y_beacons;
for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
   my $sensor = Sensor->new( $line );
   push @sensors, $sensor;

   # Check if there is a beacon on the line!
   if ($sensor->{ beacon }[0] == $y_line) {
     $y_beacons{ $sensor->{ beacon }[1] } = 1;
    }

   my $intersect = $sensor->y_intersect( $y_line );
   next unless ($intersect);
   push @ranges, $intersect;
  }

@ranges = sort { $a->[0] <=> $b->[0] } @ranges;
my $r = shift @ranges;
$pos += ($r->[1] - $r->[0] + 1);
$pos -= scalar keys %y_beacons;
my $max_pos = $r->[1] + 1;
print join( ', ', @{ $r }), "\n";
for $r (@ranges) {
  print join( ', ', @{ $r }), "\n";
  next unless ($r->[1] > $max_pos);
  my $min = ($r->[0] < $max_pos) ? $max_pos : $r->[0];
  $pos += ($r->[1] - $min + 1);
  $max_pos = $r->[1] + 1;
print "There are $pos positions unavailable\n";
 }

print "There are $pos positions unavailable\n";
exit;
