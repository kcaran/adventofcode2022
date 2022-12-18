#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use Storable qw( dclone );

my %valves;
my $time = 26;

{ package Valves;

 sub new {
  my ($class, $input) = @_;
  my $self = {
    name => '',
    rate => 0,
    next => [],
  };
  bless $self, $class;

  $input =~ s/\s+$//;
  $input =~ /^Valve (\S+) has flow rate=(\d+);(?:.*?)valves? (.*?)$/;
  $self->{ name } = $1;
  $self->{ rate } = $2;
  $self->{ next } = [ split ( ', ', $3 ) ];

  return $self;
 }
}

{ package Flows;

 sub print {
  my ($self) = @_;

  my $str = join( '', sort { $a cmp $b } ($self->{ pos }, $self->{ elephant }) );
  $str .= join( ',', sort { $a cmp $b } (keys %{ $self->{ visited } }) );

  return $str;
 }

 sub max {
   my ($self, $minute) = @_;

   my $max = $self->{ pressure };
   for my $v (keys %valves) {
     next if (!$valves{ $v }{ rate } || ($self->{ visited }{ $v } && $self->{ visited }{ $v } > 0));
     $max += ($time - $minute) * $valves{ $v }{ rate };
    }

   return $max;
  }

 sub next {
  my ($self, $elephant, $minute) = @_;

  my @next;
  my $me = $elephant ? $self->{ elephant } : $self->{ pos };
  my $him = $elephant ? $self->{ pos } : $self->{ elephant };
  if (($valves{ $me }{ rate } > 0) && !$self->{ visited }{ $me } ) {
    for my $m (@{ $valves{ $him }{ next } }) {
      my $clone = Storable::dclone( $self );
      my $total = ($time - $minute) * $valves{ $me }{ rate };
      $clone->{ visited }{ $me } = $total;
      $clone->{ pressure } += $total;
      if ($elephant) {
        $clone->{ pos } = $m;
       }
      else {
        $clone->{ elephant } = $m;
       }
      push @next, $clone;
     }

    # Check if we should both turn our valves on
    if ($elephant && $me ne $him) {
      if (($valves{ $him }{ rate } > 0) && !$self->{ visited }{ $him } ) {
        my $clone = Storable::dclone( $self );
        my $total = ($time - $minute) * $valves{ $me }{ rate };
        $clone->{ visited }{ $me } = $total;
        $clone->{ pressure } += $total;
        $total = ($time - $minute) * $valves{ $him }{ rate };
        $clone->{ visited }{ $him } = $total;
        $clone->{ pressure } += $total;
        push @next, $clone;
       }
     }
   }

  return @next;
 }

 sub moves {
  my ($self) = @_;

  my @next;

  for my $me (@{ $valves{ $self->{ pos } }{ next } }) {
    for my $el (@{ $valves{ $self->{ elephant } }{ next } }) {
      #next if ($me eq $el);
      #next if (defined( $self->{ visited }{ $v } ));
      my $clone = Storable::dclone( $self );
      $clone->{ pos } = $me;
      $clone->{ elephant } = $el;
      push @next, $clone;
     }
   }

  return @next;
 }

 sub new {
  my ($class) = @_;
  my $self = {
    pos => 'AA',
    elephant => 'AA',
    pressure => 0,
    visited => {},
  };
  bless $self, $class;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input16.txt';
for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
   my $valve = Valves->new( $line );
   $valves{ $valve->{ name } } = $valve;
  }

my $max_pressure = 0;
my @flows = ( Flows->new() );
my %states;
for my $minute (1 .. $time)  {
  print "$minute: ", scalar( @flows ), "\n";
  my @next = ();
  for my $f (@flows) {
    my @me = $f->next( 0, $minute );
    my @el = $f->next( 1, $minute );
    push @next, @me if (@me);
    push @next, @el if (@el);

    my @moves = $f->moves( $minute );
    push @next, @moves;
   }

  # Only choose the best move from each position
  @flows = ();
  for my $f (sort { $a->print() cmp $b->print() || $b->{ pressure } <=> $a->{ pressure } } @next) {
    my $str = $f->print();
    if (!defined($states{ $str }) || $states{ $str } < $f->{ pressure }) {
      if ($f->max( $minute ) > $max_pressure) {
        push @flows, $f;
        $max_pressure = $f->{ pressure } if ($max_pressure < $f->{ pressure });
        $states{ $str } = $f->{ pressure };
       }
     }
   }
 }

for my $f (@flows) {
    $max_pressure = $f->{ pressure } if ($max_pressure < $f->{ pressure });
 }

print "The most pressure after $time mins is $max_pressure\n";

exit;
