#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Packet;

 sub new {
  my ($class, $input) = @_;
  my $self = {
    vals => [],
  };
  $self->{ input } = $input;
  bless $self, $class;

  if ($input =~ /^\d+$/) {
    $self->{ vals }[0] = $input;
    return $self;
   }

  while ((my $next = substr( $input, 0, 1, '' )) ne ']') {
    die "Illegal input $next . $input" unless ($next eq '[' || $next eq ',');
    if ($input =~ s/^(\d+)//) {
      push @{ $self->{ vals } }, $1;
     }
    elsif (substr( $input, 0, 1 ) ne ']') {
      my $list = Packet->new( $input );
      $input = $list->{ input };
      push @{ $self->{ vals } }, $list;
     }
   }

  return $self;
 }
}

1;
