#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use Storable qw( dclone );

my @directions = ( '>', 'v', '<', '^' );

{ package Map;

sub max_x {
  my ($self, $y) = @_;

  my $dot = index( $self->{ rows }[$y], '.' );
  my $space = index( $self->{ rows }[$y], ' ', $dot );

  return ($space > 0) ? $space : length( $self->{ rows }[$y] ) - 1;
 }

sub max_y {
  my ($self, $x) = @_;

  my $y = @{ $self->{ rows } } - 1;
  while (length( $self->{ rows }[$y] ) < $x + 1 || substr( $self->{ rows }[$y], $x, 1 ) eq ' ') {
    $y--;
   }

  return $y;
 }

sub min_x {
  my ($self, $y) = @_;

  my $dot = index( $self->{ rows }[$y], '.' );
  my $wall = index( $self->{ rows }[$y], '#' );

  return ($dot < $wall) ? $dot : $wall;
 }

sub min_y {
  my ($self, $x) = @_;

  my $y = 0;
  while (length( $self->{ rows }[$y] ) < $x + 1 || substr( $self->{ rows }[$y], $x, 1 ) eq ' ') {
    $y++;
   }

  return $y;
 }

sub tile {
  my ($self, $y, $x) = @_;

  return length( $self->{ rows }[$y] ) > $x ? substr( $self->{ rows }[$y], $x, 1 ) : ' ';
 }

sub turn {
  my ($self, $dir) = @_;

  my $shift = ($dir eq 'L') ? 3 : 1;
  $self->{ dir } = ($self->{ dir } + $shift) % 4;

  return $self;
 }

sub move {
  my ($self, $dist) = @_;

  my ($y, $x) = ($self->{ pos }[0], $self->{ pos }[1]);
  my $dir = $directions[ $self->{ dir } ];
  while ($dist > 0) {
    if ($dir eq '>') {
      if ($x == $self->max_x( $y ) || $self->tile( $y, $x + 1 ) eq ' ') {
        my $min_x = $self->min_x( $y );
        $x = $min_x if ($self->tile( $y, $min_x ) eq '.');
       }
      elsif ($self->tile( $y, $x + 1 ) eq '#') {
        $dist = 0;
       }
      else {
        $x++;
       }
     }
    if ($dir eq 'v') {
      if ($y == $self->max_y( $x ) || $self->tile( $y + 1, $x ) eq ' ') {
        my $min_y = $self->min_y( $x );
        $y = $min_y if ($self->tile( $min_y, $x ) eq '.');
       }
      elsif ($self->tile( $y + 1, $x ) eq '#') {
        $dist = 0;
       }
      else {
        $y++;
       }
     }
    if ($dir eq '<') {
      if ($x == $self->min_x( $y ) || $self->tile( $y, $x - 1 ) eq ' ') {
        my $max_x = $self->max_x( $y );
        $x = $max_x if ($self->tile( $y, $max_x ) eq '.');
       }
      elsif ($self->tile( $y, $x - 1 ) eq '#') {
        $dist = 0;
       }
      else {
        $x--;
       }
     }
    if ($dir eq '^') {
      if ($y == $self->min_y( $x ) || $self->tile( $y - 1, $x ) eq ' ') {
        my $max_y = $self->max_y( $x );
        $y = $max_y if ($self->tile( $max_y, $x ) eq '.');
       }
      elsif ($self->tile( $y - 1, $x ) eq '#') {
        $dist = 0;
       }
      else {
        $y--;
       }
     }
    $dist--;
   }

  $self->{ pos } = [ $y, $x ];
  return $self;
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
    rows => [],
    max_x => 0,
    pos => [],
    dir => 0,
  };

  bless $self, $class;
  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  while ((my $row = shift @lines) ne '') {
    push @{ $self->{ rows } }, $row;
   }
  $self->{ path } = shift @lines;
  $self->{ pos } = [0, index( $self->{ rows }[0], '.' ) ];

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input22.txt';

my $map = Map->new( $input_file );

while ($map->{ path } =~ /(\d+)([LR]|$)/g) {
  $map->move( $1 );
  $map->turn( $2 ) if ($2);
  print "$1,$2: ", $map->{ pos }[0] + 1, ", ", $map->{ pos }[1] + 1, " $directions[$map->{dir}]\n";
 }

my $password = 1000 * ($map->{ pos }[0] + 1) + 4 * ($map->{ pos }[1] + 1) + $map->{ dir };

print "The password is $password\n";

exit;
