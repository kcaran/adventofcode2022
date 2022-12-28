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

sub cube_y_d {
  my ($self, $y, $x) = @_;

  if ($y == 150 && $x >= 50 && $x < 100) {
    return ($x + 100, 49, 2)
   }
  elsif ($y == 200 && $x < 50) {
    return (0, $x + 100, 1);
   }
  elsif ($y == 50 && $x > 100) {
    return ($x - 50, 99, 2 );
   }
  die "Bad cube ($y, $x)";

  return;
 }

sub cube_y_u {
  my ($self, $y, $x) = @_;

  if ($y < 0 && $x < 100) {
    return( $x + 100, 0, 0 );
   }
  elsif ($y < 0 && $x >= 100) {
    return( 199, $x - 100, 3 );
   }
  elsif ($y == 99 && $x < 50) {
    return( $x + 50, 50, 0 );
   }

  die "Bad cube ($y, $x)";

  return;
 }

sub cube_x_l {
  my ($self, $y, $x) = @_;

  if ($y < 50) {
    return (149 - $y, 0, 0 );
   }
  elsif ($y < 100) {
    return( 100, $y - 50, 1 );
   }
  elsif ($y < 150) {
    return( 149 - $y, 50, 0 );
   }
  else {
    return( 0, $y - 100, 1 );
   }
 }

sub cube_x_r {
  my ($self, $y, $x) = @_;

  if ($y < 50) {
    return( 149 - $y, 99, 2 );
   }
  elsif ($y < 100) {
    return( 49, $y + 50, 3 );
   }
  elsif ($y < 150) {
    return( 149 - $y, 149, 2 );
   }
  else {
    return( 149, $y - 100, 3 );
   }
 }

sub move {
  my ($self, $dist) = @_;

  my ($y, $x) = ($self->{ pos }[0], $self->{ pos }[1]);
  my $dir = $directions[ $self->{ dir } ];
  while ($dist > 0) {
    if ($dir eq '>') {
      if ($x == $self->max_x( $y ) || $self->tile( $y, $x + 1 ) eq ' ') {
        my ($new_y, $new_x, $new_dir) = $self->cube_x_r( $y, $x + 1 );
        if ($self->tile( $new_y, $new_x ) eq '.') {
          $x = $new_x;
          $y = $new_y;
          $self->{ dir } = $new_dir;
          $dir = $directions[$new_dir];
         }
        die "Bad tile ($new_y, $new_x)" unless ($self->tile( $new_y, $new_x ) ne ' ');
       }
      elsif ($self->tile( $y, $x + 1 ) eq '#') {
        $dist = 0;
       }
      else {
        $x++;
       }
     }
    elsif ($dir eq 'v') {
      if ($y == $self->max_y( $x ) || $self->tile( $y + 1, $x ) eq ' ') {
        my ($new_y, $new_x, $new_dir) = $self->cube_y_d( $y + 1, $x );
        if ($self->tile( $new_y, $new_x ) eq '.') {
          $x = $new_x;
          $y = $new_y;
          $self->{ dir } = $new_dir;
          $dir = $directions[$new_dir];
         }
        die "Bad tile ($new_y, $new_x)" unless ($self->tile( $new_y, $new_x ) ne ' ');
       }
      elsif ($self->tile( $y + 1, $x ) eq '#') {
        $dist = 0;
       }
      else {
        $y++;
       }
     }
    elsif ($dir eq '<') {
      if ($x == $self->min_x( $y ) || $self->tile( $y, $x - 1 ) eq ' ') {
        my ($new_y, $new_x, $new_dir) = $self->cube_x_l( $y, $x - 1 );
        if ($self->tile( $new_y, $new_x ) eq '.') {
          $x = $new_x;
          $y = $new_y;
          $self->{ dir } = $new_dir;
          $dir = $directions[$new_dir];
         }
        die "Bad tile ($new_y, $new_x)" unless ($self->tile( $new_y, $new_x ) ne ' ');
       }
      elsif ($self->tile( $y, $x - 1 ) eq '#') {
        $dist = 0;
       }
      else {
        $x--;
       }
     }
    elsif ($dir eq '^') {
      if ($y == $self->min_y( $x ) || $self->tile( $y - 1, $x ) eq ' ') {
        my ($new_y, $new_x, $new_dir) = $self->cube_y_u( $y - 1, $x );
        if ($self->tile( $new_y, $new_x ) eq '.') {
          $x = $new_x;
          $y = $new_y;
          $self->{ dir } = $new_dir;
          $dir = $directions[$new_dir];
         }
        die "Bad tile ($new_y, $new_x)" unless ($self->tile( $new_y, $new_x ) ne ' ');
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
