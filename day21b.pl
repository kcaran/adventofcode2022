#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

# For part 2, I did a little manual testing to get the starting point
my $humn = $ARGV[1] || 3375700000000;

my %monkeys;
{ package Monkey;

 sub new {
  my ($class, $input) = @_;
  my $self = {
  };
  bless $self, $class;

  my ($name, $yell) = ($input =~ /^(\w+): (.*?)$/);
  $self->{ name } = $name;

  if ($name eq 'humn') {
    $self->{ yell } = sub { return $humn };
   }
  elsif ($yell =~ /^\d+$/) {
    $self->{ yell } = sub { return $yell };
    return $self;
   }
  else {
    my ($m1, $op, $m2) = ($yell =~ /^(\S+)\s(\S)\s(\S+)$/);
    if ($name eq 'root') {
      $self->{ yell } = sub {
        print "\$humn = ", $monkeys{ humn }{ yell }(), "\n";
        print "\$m1 ($m1) = ", $monkeys{ $m1 }{ yell }(), "\n";
        print "\$m2 ($m2) = ", $monkeys{ $m2 }{ yell }(), "\n";
        return eval "\$monkeys{ $m1 }{ yell }() cmp \$monkeys{ $m2 }{ yell }()";
      };
     }
    else {
      $self->{ yell } = sub {
        return eval "\$monkeys{ $m1 }{ yell }() $op \$monkeys{ $m2 }{ yell }()";
      };
    }
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input21.txt';
for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  my $m = Monkey->new( $line );
  $monkeys{ $m->{ name } } = $m;
 }

my $diff = 10000000;
while ($monkeys{ root }{ yell }() != 0) {
  my $cmp;
  while (($cmp = $monkeys{ root }{ yell }()) > 0) {
    $humn += $diff;
   }
  $humn -= $diff unless ($cmp == 0);
  $diff = $diff / 10;
print "KAC: $humn $cmp\n";
 }

print "The root monkey yells ", $monkeys{ root }{ yell }(), " for $humn\n";

exit;
