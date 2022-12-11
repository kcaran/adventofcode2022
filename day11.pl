#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my @monkeys;

my $divisible = 1;

{ package Monkey;

 sub throw {
   my ($self, $num, $level) = @_;

   my $monkey = $monkeys[$num];
   push @{ $monkey->{ items }  }, $level
  }

 sub inspect {
   my ($self) = @_;

   while (my $old = shift @{ $self->{ items } }) {
     $self->{ count }++;
     my $new;
     eval $self->{ op };
     $new = $new % $divisible;
     my $next = ($new % $self->{ test }) ? $self->{ false } : $self->{ true };
     $self->throw( $next, $new );
    }

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
    count => 0,
  };
  bless $self, $class;

  my ($num) = $input =~ /^Monkey (\d+)/ms;
  my ($itemstr) = $input =~ /items: (.*?)$/ms;
  my ($op) = $input =~ /Operation: (.*?)$/ms;
  my ($test) = $input =~ /divisible by (\d+)$/ms;
  my ($true) = $input =~ /true:(?:.*?)(\d+)$/ms;
  my ($false) = $input =~ /false(?:.*?)(\d+)$/ms;

  $self->{ num } = $num;
  $self->{ items } = [ split( ', ', $itemstr ) ];
  $op =~ s/(new|old)/\$$1/g;
  $self->{ op } = $op;
  $self->{ test } = $test;
  $self->{ true } = $true;
  $self->{ false } = $false;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input11.txt';
my $input = Path::Tiny::path( $input_file )->slurp_utf8();

# Match to blank line (or end of file)
while ($input =~ /(\S.*?)(?:^$|\Z)/smg) {
  my $monkey = Monkey->new( $1 );
  $divisible *= $monkey->{ test };
  push @monkeys, $monkey;
 }

for my $round (1 .. 10000) {
  for my $m (@monkeys) {
    $m->inspect();
   }
 }

my @biz = sort { $b <=> $a } map { $_->{ count } } @monkeys;

print "The level of monkey business is ", $biz[0] * $biz[1], "\n";

exit;
