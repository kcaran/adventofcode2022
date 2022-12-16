#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Map;

use List::Util qw( max min );

  sub sand_tiles {
    my ($self) = @_;
   }

  sub print {
    my ($self, $depth) = @_;

    my $map = '';
    for my $y (0 .. $self->{ max_y }) {
      for my $x ($self->{ min_x } .. $self->{ max_x }) {
        $map .= $self->tile( [$y, $x] ) || '.';
       }
      $map .= "\n";
     }

    return $map;
   }

  sub bounds {
    my ($self, $y, $x) = @_;
    my $bounds = [ -1, -1 ];

    my $left = $x;
    while ($self->open( $y, $left - 1 ) && !$self->open( $y + 1, $left )) {
      $self->{ tiles }{ "$y,$left" } = 1;
      $left--;
     }
    $bounds->[0] = $left if (!$self->open( $y + 1, $left ));

    my $right = $x;
    while ($self->open( $y, $right + 1 ) && !$self->open( $y + 1, $right )) {
      $self->{ tiles }{ "$y,$right" } = 1;
      $right++;
     }
    $bounds->[1] = $right if (!$self->open( $y + 1, $right ));

    return $bounds if ($bounds->[0] >= 0 && $bounds->[1] >= 0);
   }

  sub overflow {
    my ($self, $y, $x) = @_;
    my $overflow = [];

    my $left = $x;
    while ($self->open( $y, $left ) && !$self->open( $y + 1, $left )) {
      $self->{ tiles }{ "$y,$left" } = 1;
      $left--;
     }
    if ($self->open( $y + 1, $left )) {
      $self->{ tiles }{ "$y,$left" } = 1;
#     print "overflow left at: ($y,$left)\n";
      push @{ $overflow }, [ $y, $left ] 
     }

    my $right = $x;
    while ($self->open( $y, $right ) && !$self->open( $y + 1, $right )) {
      $self->{ tiles }{ "$y,$right" } = 1;
      $right++;
     }
    if ($self->open( $y + 1, $right )) {
      $self->{ tiles }{ "$y,$right" } = 1;
#     print "overflow right at: ($y,$right)\n";
      push @{ $overflow }, [ $y, $right ] 
     }

    return $overflow;
   }

  sub open {
    my ($self, $y, $x) = @_;

    my $point = $self->{ map }[$y][$x] || '.';

    return ($point eq '.');
   }

  sub tile {
    my ($self, $pos, $val) = @_;

    if (defined( $val )) {
      $self->{ map }[$pos->[0]][$pos->[1]] = $val;
     }

    return '#' if ($pos->[0] == $self->{ max_y });

    return $self->{ map }[$pos->[0]][$pos->[1]];
   }

  sub sand {
    my ($self) = @_;

    my ($y, $x) = (0, 500);

    my $placed;
    while (!$placed && $y <= $self->{ max_y }) {
      if ($self->tile( [$y + 1, $x] )) {
        if ($self->tile( [$y + 1, $x - 1] )) {
          if ($self->tile( [$y + 1, $x + 1] )) {
            $placed = 1;
           }
          else {
            $x = $x + 1;
            $self->{ max_x } = $x if ($self->{ max_x } < $x);
           }
         }
        else {
          $x = $x - 1;
          $self->{ min_x } = $x if ($self->{ min_x } > $x);
         }
       }
      $y++ unless ($placed);
     }

    die "Somehow we reached the floor!" if ($y > $self->{ max_y });
    $self->tile( [$y, $x], 'o' );
    $self->{ sand }++;

    return ($y != 0 || $x != 500) ? 1 : 0;
   }

  sub new {
    my ($class, $input_file) = @_;
    my $self = {
     map => [],
     min_x => 10000,
     max_x => 0,
     min_y => 10000,
     max_y => 0,
     tiles => {},
     sand => 0,
    };
    bless $self, $class;

    for my $scan ( Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
      my $prev;
      while ($scan =~ /(\d+),(\d+)(?:(?: -> )|$)/g) {
        my ($x, $y) = ($1, $2);
        $self->{ min_x } = $x - 1 unless ($self->{ min_x } <= $x - 1);
        $self->{ max_x } = $x + 1 unless ($self->{ max_x } >= $x + 1);
        $self->{ min_y } = $y  unless ($self->{ min_y } <= $y);
        $self->{ max_y } = $y  unless ($self->{ max_y } >= $y);

        if ($prev) {
          for my $y1 (min( $prev->[0], $y ) .. max( $prev->[0], $y )) {
            for my $x1 (min( $prev->[1], $x ) .. max( $prev->[1], $x )) {
              $self->{ map }[$y1][$x1] = '#';
             }
           }
         }
        $prev = [$y, $x];
       }
     }

    $self->{ max_y } += 2;

    return $self;
   }
}

my $input_file = $ARGV[0] || 'input14.txt';
my $map = Map->new( $input_file );
my $tiles;

while ($map->sand()) {
  print $map->print() if (0);
 }

print $map->print();

print "There are ", $map->{ sand }, " tiles with sand\n";

exit;
