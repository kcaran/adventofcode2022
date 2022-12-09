#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Trees;

 sub maxscore {
  my ($self) = @_;
  my $max = 0;

  for my $row (1 .. @{ $self->{ rows } } - 2) {
    for my $col (1 .. @{ $self->{ columns } } - 2) {
      my $score = $self->scenic( $row, $col );
      $max = $score if ($score > $max);
     }
   }

  return $max;
 }

 sub scenic {
  my ($self, $row, $col) = @_;

  my $shorter = substr( $self->{ rows }[$row], $col, 1 ) - 1;
  return 0 if ($shorter < 0);

  my $score = 1;
  my $view;
  my $pre = substr( $self->{ rows }[$row], 0, $col );
  ($view) = ($pre =~ /([0-$shorter]+)$/ );
  $view ||= '';
  $score *= length( $view ) + (length( $view ) < length( $pre ) ? 1 : 0);

  my $post = substr( $self->{ rows }[$row], $col + 1 );
  ($view) = ($post =~ /^([0-$shorter]+)/ );
  $view ||= '';
  $score *= length( $view ) + (length( $view ) < length( $post ) ? 1 : 0);

  $pre = substr( $self->{ columns }[$col], 0, $row );
  ($view) = ($pre =~ /([0-$shorter]+)$/ );
  $view ||= '';
  $score *= length( $view ) + (length( $view ) < length( $pre ) ? 1 : 0);

  $post = substr( $self->{ columns }[$col], $row + 1 );
  ($view) = ($post =~ /^([0-$shorter]+)/ );
  $view ||= '';
  $score *= length( $view ) + (length( $view ) < length( $post ) ? 1 : 0);

  return $score;
 }

 sub visible {
  my ($self) = @_;

  my $visible = @{ $self->{ rows } } * 2 + (@{ $self->{ columns } } - 2) * 2;
  for my $row (1 .. @{ $self->{ rows } } - 2) {
    for my $col (1 .. @{ $self->{ columns } } - 2) {
      my $shorter = substr( $self->{ rows }[$row], $col, 1 ) - 1;
      next if ($shorter < 0);
      my $pre = substr( $self->{ rows }[$row], 0, $col );
      if ($pre =~ /^[0-$shorter]+$/) {
        $visible++;
        next;
       }
      my $post = substr( $self->{ rows }[$row], $col + 1 );
      if ($post =~ /^[0-$shorter]+$/) {
        $visible++;
        next;
       }
      $pre = substr( $self->{ columns }[$col], 0, $row );
      if ($pre =~ /^[0-$shorter]+$/) {
        $visible++;
        next;
       }
      $post = substr( $self->{ columns }[$col], $row + 1 );
      if ($post =~ /^[0-$shorter]+$/) {
        $visible++;
        next;
       }
     }
   }

  return $visible;
 }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    rows => [],
    columns => [],
  };

  my @lines = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );
  for my $row (0 .. @lines - 1) {
    $self->{ rows }[$row] = $lines[$row];
    my @nums = split( '', $lines[$row] );
    for my $col (0 .. @nums - 1) {
      $self->{ columns }[$col] .= $nums[$col];
     }
   }

  bless $self, $class;
  return $self;
 }
}

my $input_file = $ARGV[0] || 'input08.txt';
my $trees = Trees->new( $input_file );

print "There are ", $trees->visible(), " visible trees\n";

print "The highest scenic score is ", $trees->maxscore(), "\n";

exit;
