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

  while ((my $next = substr( $self->{ input }, 0, 1, '' )) ne ']') {
    die "Illegal input $next . $self->{ input }" unless ($next eq '[' || $next eq ',');
    if ($self->{ input } =~ s/^(\d+)//) {
      push @{ $self->{ vals } }, $1;
     }
    elsif (substr( $self->{ input }, 0, 1 ) ne ']') {
      my $list = Packet->new( $self->{ input } );
      $self->{ input } = $list->{ input };
      push @{ $self->{ vals } }, $list;
     }
   }

  return $self;
 }
}

1;
