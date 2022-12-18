#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Cubes;

 sub sides {
   my ($self, $cube) = @_;

   my ($x, $y, $z) = split( ',', $cube );

   return (
	($x - 1) . ",$y,$z",
	($x + 1) . ",$y,$z",
	"$x," . ($y - 1) . ",$z",
	"$x," . ($y + 1) . ",$z",
	"$x,$y," . ($z - 1),
	"$x,$y," . ($z + 1),
	);
  }

 sub visible {
   my ($self) = @_;

   my $visible = 0;

   for my $cube (keys %{ $self->{ cubes } }) {
     for my $side ($self->sides( $cube )) {
       $visible++ unless ($self->{ cubes }{ $side });
      }
    }

   return $visible;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    cubes => {},
    max_x => 0,
    max_y => 0,
    max_z => 0,
  };

  for my $cube (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
    my ($x, $y, $z) = split( ',', $cube );
    $self->{ max_x } = $x if ($x > $self->{ max_x });
    $self->{ max_y } = $y if ($y > $self->{ max_y });
    $self->{ max_z } = $z if ($z > $self->{ max_z });
    $self->{ cubes }{ $cube } = 1;
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input18.txt';
my $cubes = Cubes->new( $input_file );

print "There are ", $cubes->visible(), " sides visible\n";

#
# part 2 - try all of the outside cubes and their neighbors. If we
# hit a rock we won't try any more. Flood Fill algorithm
#
my $exterior = 0;
my @tries = ( "-1,-1,-1" );
my %visited;
while (my $pos = shift @tries) {
  my ($x, $y, $z) = split( ',', $pos );
  $exterior++ if ($cubes->{ cubes }{ $pos });
  next if ($visited{ $pos } || $cubes->{ cubes }{ $pos });
  $visited{ $pos } = 1;
  push @tries, "$x,$y," . ($z - 1) if ($z >= 0);
  push @tries, "$x,$y," . ($z + 1) if ($z <= $cubes->{ max_z });
  push @tries, "$x," . ($y - 1) . ",$z" if ($y >= 0);
  push @tries, "$x," . ($y + 1) . ",$z" if ($y <= $cubes->{ max_y });
  push @tries, ($x - 1) . ",$y,$z" if ($x >= 0);
  push @tries, ($x + 1) . ",$y,$z" if ($x <= $cubes->{ max_x });
 }

print "There are $exterior exterior sides\n";

exit;
