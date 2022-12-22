#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my %monkeys;
{ package Monkey;

 sub new {
  my ($class, $input) = @_;
  my $self = {
  };
  bless $self, $class;

  my ($name, $yell) = ($input =~ /^(\w+): (.*?)$/);
  $self->{ name } = $name;

  if ($yell =~ /^\d+$/) {
    $self->{ yell } = sub { return $yell };
    return $self;
   }
  else {
    my ($m1, $op, $m2) = ($yell =~ /^(\S+)\s(\S)\s(\S+)$/);
    $self->{ yell } = sub {
      return eval "\$monkeys{ $m1 }{ yell }() $op \$monkeys{ $m2 }{ yell }()";
    };
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input21.txt';
for my $line (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
  my $m = Monkey->new( $line );
  $monkeys{ $m->{ name } } = $m;
 }

print "The root monkey yells ", $monkeys{ root }{ yell }(), "\n";

exit;
