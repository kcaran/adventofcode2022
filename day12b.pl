#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Map;

 sub moves {
   my ($self, $pos, $steps) = @_;

   my @moves;
   my ($y, $x) = split( ',', $pos );
   my $val = $self->{ map }[$y][$x];
   if ($y > 0) {
     my $next = ($y - 1) . ",$x";
     push @moves, [ $next, $steps + 1 ] if (!$self->{ visited }{ $next } && $self->{ map }[$y - 1][$x] <= $val + 1)
    }

   if ($y < $self->{ max_y }) {
     my $next = ($y + 1) . ",$x";
     push @moves, [ $next, $steps + 1 ] if (!$self->{ visited }{ $next } && $self->{ map }[$y + 1][$x] <= $val + 1)
    }

   if ($x > 0) {
     my $next = "$y," . ($x - 1);
     push @moves, [ $next, $steps + 1 ] if (!$self->{ visited }{ $next } && $self->{ map }[$y][$x - 1] <= $val + 1)
    }

   if ($x < $self->{ max_x }) {
     my $next = "$y," . ($x + 1);
     push @moves, [ $next, $steps + 1 ] if (!$self->{ visited }{ $next } && $self->{ map }[$y][$x + 1] <= $val + 1)
    }

   return @moves;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    count => 0,
    map => [],
    visited => {},
    start => [],
    end => '',
    max => 0,
  };
  bless $self, $class;

  my ($y, $x) = (0, 0);
  for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
    $x = 0;
    for my $char (split( '', $line )) {
      if ($char eq 'a') {
        push @{ $self->{ start } }, "$y,$x";
       }
      if ($char eq 'S') {
        push @{ $self->{ start } }, "$y,$x";
        $char = 'a';
       }
      if ($char eq 'E') {
        $self->{ end } = "$y,$x";
        $char = 'z';
       }
      $self->{ map }[$y][$x] = ord( $char );
      $x++;
     }
    $y++;
   }
  $self->{ max_y } = @{ $self->{ map } } - 1;
  $self->{ max_x } = @{ $self->{ map }[0] } - 1;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input12.txt';
my $map = Map->new( $input_file );

my $best = ($map->{ max_y } + 1) * ($map->{ max_x } + 1);
for my $a (@{ $map->{ start } }) {
  my $dest;
  $map->{ visited } = { $a => 0 };
  my @pos = $map->moves( $a, 0 );
  while (@pos) {
    $dest = shift @pos;
    last if ($dest->[0] eq $map->{ end });
    next if (defined( $map->{ visited }{ $dest->[0] } ) && $map->{ visited }{ $dest->[0] } <= $dest->[1]);
    $map->{ visited }{ $dest->[0] } = $dest->[1];
    push @pos, $map->moves( $dest->[0], $dest->[1] );
   };
  $best = $dest->[1] if ($best > $dest->[1]) && ($dest->[0] eq $map->{ end });
 }

print "The location was reached in $best steps\n";

exit;
