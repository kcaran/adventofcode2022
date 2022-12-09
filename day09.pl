#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Rope;

 sub tail {
   my ($self, $seg) = @_;

   while (1) {
     my $y = $self->{ segs }[$seg - 1][0] - $self->{ segs }[$seg][0];
	 my $x = $self->{ segs }[$seg - 1][1] - $self->{ segs }[$seg][1];
     last if (abs($y) < 2 && abs($x) < 2);

     $self->{ segs }[$seg][0] += ($y <=> 0);
     $self->{ segs }[$seg][1] += ($x <=> 0);
     if ($seg == $self->{ tail }) {
       $self->{ visited }{ "$self->{ segs }[$seg][0],$self->{ segs }[$seg][1]" } = 1;
      }
    }

   return $self;
  }

 sub move {
   my ($self, $move) = @_;

   my ($dir, $steps) = ($move =~ /^(\w) (\d+)$/);

   while ($steps) {
     $self->{ segs }[0][0]++ if ($dir eq 'D');
     $self->{ segs }[0][0]-- if ($dir eq 'U');
     $self->{ segs }[0][1]++ if ($dir eq 'R');
     $self->{ segs }[0][1]-- if ($dir eq 'L');
     for my $s (1 .. $self->{ tail }) {
       $self->tail( $s );
      }
     $steps--;
    }

   return $self;
  }

 sub new {
  my ($class, $segments) = @_;
  my $self = {
    visited => { "0,0" => 1 },
    segs => [],
  };

  $segments ||= 2;
  $self->{ tail } = $segments - 1;
  while ($segments) {
    push @{ $self->{ segs } }, [0, 0];
    $segments--;
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input09.txt';
my $segments = $ARGV[1] || 2;
my @moves = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );
my $rope = Rope->new( $segments );
for my $m (@moves) {
  $rope->move( $m );
 }

print "The tail has visited ", scalar keys %{ $rope->{ visited } }, "\n";

exit;
