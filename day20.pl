#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Code;

 sub code {
  my ($self, $count) = @_;

  my $val = $self->{ zero };
  $count = $count % scalar( @{ $self->{ nums } } );
  while ($count > 0) {
    $val = $val->{ next };
    $count--;
   }
  return $val->{ num };
 }

 sub mix {
  my ($self, $num) = @_;

  my $loop = scalar( @{ $self->{ nums } } ) - 1;
  my $count = $num->{ num } > 0 ? ($num->{ num } % $loop) : -(abs($num->{ num }) % $loop);

  while ($count != 0) {
    if ($count > 0) {
      my $next = $num->{ next };
      my $prev = $num->{ prev };
      my $new_next = $next->{ next };
      $prev->{ next } = $next;
      $next->{ prev } = $prev;
      $next->{ next } = $num;
      $num->{ prev } = $next;
      $num->{ next } = $new_next;
      $new_next->{ prev } = $num;
      $count--;
     }
    else {
      my $next = $num->{ next };
      my $prev = $num->{ prev };
      my $new_prev = $prev->{ prev };
      $next->{ prev } = $prev;
      $prev->{ next } = $next;
      $prev->{ prev } = $num;
      $num->{ next } = $prev;
      $num->{ prev } = $new_prev;
      $new_prev->{ next } = $num;
      $count++;
     }
   }

  return $self;
 }

 sub new {
  my ($class, $input_file, $key) = @_;
  my $self = {
    zero => '',
    nums => [],
  };
  bless $self, $class;

  my $prev;
  for my $num (Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } )) {
     $num *= $key if ($key);
     my $ref = { num => $num };
     if ($prev) {
       $prev->{ next } = $ref;
       $ref->{ prev } = $prev;
      }
     $prev = $ref;
     push @{ $self->{ nums } }, $ref;
     $self->{ zero } = $ref if ($num == 0);
    }

  my $first = $self->{ nums }[0];
  my $last = $self->{ nums }[-1];
  $first->{ prev } = $last;
  $last->{ next } = $first;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input20.txt';
my $key = $ARGV[1];
my $mix_count = $key ? 10 : 1;
my $code = Code->new( $input_file, $key );
while ($mix_count > 0) {
  for my $num (@{ $code->{ nums } }) {
    $code->mix( $num );
   }
  $mix_count--;
 }

my $x1000 = $code->code( 1000 );
my $x2000 = $code->code( 2000 );
my $x3000 = $code->code( 3000 );

print "The sum of $x1000 + $x2000 + $x3000 is ", $x1000 + $x2000 + $x3000, "\n";

exit;
