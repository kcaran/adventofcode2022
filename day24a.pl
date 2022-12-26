#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use Storable qw( dclone );

{ package Path;

sub moves {
  my ($self, $map) = @_;

  $self->{ moves }++;
  my @next = ();
  my ($pos_y, $pos_x) = split( ',', $self->{ pos } );
  if ($pos_y >= 0 && !$map->{ grid }{ $self->{ pos } }) {
    push @next, $self;
   }
  if ($pos_y > 0 && !$map->{ grid }{ ($pos_y - 1) . ",$pos_x" }) {
    my $clone = Storable::dclone( $self );
    $clone->{ pos } = ($pos_y - 1) . ",$pos_x";
    push @next, $clone;
   }
  if ($pos_y < $map->{ y_end } - 1 && !$map->{ grid }{ ($pos_y + 1) . ",$pos_x" }) {
    my $clone = Storable::dclone( $self );
    $clone->{ pos } = ($pos_y + 1) . ",$pos_x";
    push @next, $clone;
   }
  if ($pos_y >= 0 && $pos_x > 0 && !$map->{ grid }{ "$pos_y," . ($pos_x - 1) }) {
    my $clone = Storable::dclone( $self );
    $clone->{ pos } = "$pos_y," . ($pos_x - 1);
    push @next, $clone;
   }
  if ($pos_y >= 0 && $pos_x < $map->{ x_max } && !$map->{ grid }{ "$pos_y," . ($pos_x + 1) }) {
    my $clone = Storable::dclone( $self );
    $clone->{ pos } = "$pos_y," . ($pos_x + 1);
    push @next, $clone;
   }
  if ($pos_y == $map->{ y_end } - 1 && $pos_x == $map->{ x_end }) {
    my $clone = Storable::dclone( $self );
    $clone->{ pos } = ($pos_y + 1) . ",$pos_x";
    $clone->{ exit } = 1;
    @next = ( $clone );
   }

  return @next;
 }

sub new {
  my ($class, $map) = @_;

  my $self = {
    pos => '',
    moves => 0,
  };

  $self->{ pos } = "-1,$map->{ x_start }";
  bless $self, $class;

  return $self;
 }
}


{ package Map;

my $dirs = {
	'>' => [ 0, 1 ],
	'<' => [ 0, -1 ],
	'^' => [ -1, 0 ],
	'v' => [ 1, 0 ],
 };


sub winds {
  my ($self) = @_;

  $self->{ grid } = {};
  for my $wind (@{ $self->{ winds } }) {
    my $dir = $dirs->{ $wind->{ dir } };
    my $pos = [ $wind->{ pos }[0] + $dir->[0], $wind->{ pos }[1] + $dir->[1] ];
    $pos->[0] = $self->{ y_end } - 1 if ($pos->[0] < 0);
    $pos->[0] = 0 if ($pos->[0] > $self->{ y_end } - 1);
    $pos->[1] = $self->{ x_max } if ($pos->[1] < 0);
    $pos->[1] = 0 if ($pos->[1] > $self->{ x_max });
    $self->{ grid }{ "$pos->[0],$pos->[1]" } = 1;
    $wind->{ pos } = $pos;
   }
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
    grid => {},
    winds => [],
    moves => 0,
  };

  bless $self, $class;
  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  my $top = shift @lines;
  $self->{ x_start } = index( $top, 'E' ) - 1;
  $self->{ x_max } = length( $top ) - 3;
  my $y = 0;
  for my $line (@lines) {
    if ($line =~ /^##/) {
      $self->{ y_end } = $y;
      $self->{ x_end } = index( $line, '.' ) - 1;
      next;
     }
    $line =~ s/#//g;
    for my $x (0 .. length( $line ) - 1) {
      my $char = substr( $line, $x, 1 );
      if ($char ne '.') {
        push @{ $self->{ winds } }, { dir => $char, pos => [ $y, $x ] };
       }
     }
    $y++;
   }
  $self->{ pos } = "-1,$self->{ x_start }";

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input24.txt';

my $map = Map->new( $input_file );

my @moves = ( Path->new( $map ) );
while (1) {
  $map->winds();
  my %next;
  for my $m (@moves) {
    if ($m->{ exit }) {
      print "It took $m->{ moves } moves\n";
      exit;
     }
    for my $n ($m->moves( $map )) {
      $next{ $n->{ pos } } = $n;
     }
   }
  @moves = values %next;
 }

exit;
