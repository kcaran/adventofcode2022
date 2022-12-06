#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Stacks;

sub top {
  my ($self) = @_;

  my $top = '';

  for my $stack (@{ $self->{ stacks } }) {
    $top .= $stack->[-1];
   }

  return $top;
 }

sub move {
  my ($self) = @_;

  for my $move (@{ $self->{ moves } }) {
    my @from = splice( @{ $self->{ stacks }[ $move->{ from } ] }, -$move->{ num } );
    push( @{ $self->{ stacks }[ $move->{ to } ] }, @from );
    next;
   }

  return $self;
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
    stacks => [],
    moves => [],
  };

  my @lines = Path::Tiny::path( $input_file )->lines( { chomp => 1 } );
  for my $line (@lines) {
    $line =~ s/\s+$//;
    next unless ($line);
    next if ($line =~ /^ 1/);

    if ($line =~ /^move (\d+) from (\d+) to (\d+)/) {
      push @{ $self->{ moves } }, { num => $1, from => $2 - 1, to => $3 - 1 };
     }
    else {
      my $count = 0;
      for my $stack ($line =~ /(\s{3}|\[.\])(?:\s|$)/g) {
        $stack =~ tr/ []//d;
        unshift @{ $self->{ stacks }[$count] }, $stack if ($stack);
        $count++;
       }
     }
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input05.txt';

my $stacks = Stacks->new( $input_file );
$stacks->move();

print "The top of each stack is now ", $stacks->top(), "\n";


exit;
