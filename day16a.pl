#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use Storable qw( dclone );

my %valves;

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

  my $str = $self->{ pos };
  $str .= join( ',', sort { $a cmp $b } (keys %{ $self->{ visited } }) );

  return $str;
 }

 sub max {
   my ($self, $minute) = @_;

   my $max = $self->{ pressure };
   for my $v (keys %valves) {
     next if (!$valves{ $v }{ rate } || ($self->{ visited }{ $v } && $self->{ visited }{ $v } > 0));
     $max += (30 - $minute) * $valves{ $v }{ rate };
    }

   return $max;
  }

 sub next {
  my ($self, $minute) = @_;

  my @next;
  if (($valves{ $self->{ pos } }{ rate } > 0) && !$self->{ visited }{ $self->{ pos } } ) {
    my $clone = Storable::dclone( $self );
    my $total = (30 - $minute) * $valves{ $self->{ pos } }{ rate };
    $clone->{ visited }{ $self->{ pos } } = $total;
    $clone->{ pressure } += $total;
    push @next, $clone;
   }

  for my $v (@{ $valves{ $self->{ pos } }{ next } }) {
    #next if (defined( $self->{ visited }{ $v } ));
    my $clone = Storable::dclone( $self );
    $clone->{ pos } = $v;
    push @next, $clone;
   }

  return @next;
 }

 sub new {
  my ($class) = @_;
  my $self = {
    pos => 'AA',
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
for my $minute (1..30) {
  print "$minute: ", scalar( @flows ), "\n";
  my @next = ();
  for my $f (@flows) {
    my @moves = $f->next( $minute );
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

print "The most pressure after 30 mins is $max_pressure\n";

exit;
