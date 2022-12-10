#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Cpu;

 my %cycles = (
	20 => 1,
	60 => 1,
	100 => 1,
	140 => 1,
	180 => 1,
	220 => 1,
	);

 sub print {
   my ($self) = @_;

   for my $row (@{ $self->{ crt } }) {
     print join( '', @{ $row } ), "\n";
    }

   return $self;
  }

 sub crt {
   my ($self) = @_;

   my $row = int( $self->{ clock } / 40 );
   my $col = $self->{ clock } % 40;

   my $pix = abs( $col - $self->{ x } ) < 2 ? '#' : '.';
   $self->{ crt }[$row][$col] = $pix;

   return $self;
  }

 sub clock {
   my ($self) = @_;

   $self->crt();
   $self->{ clock }++;
   if ($cycles{ $self->{ clock } }) {
     $self->{ sum } += $self->{ clock } * $self->{ x };
    }

   return $self;
  }

 sub execute {
   my ($self, $stmt) = @_;

   if ($stmt eq 'noop') {
     $self->clock();
    }
   else {
     my ($addx) = ($stmt =~ /^addx (-?\d+)$/);
die "$stmt" unless ($addx);
     $self->clock();
     $self->clock();
     $self->{ x } += $addx;
    }
 
   return $self;
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    x => 1,
    clock => 0,
    sum => 0,
    crt => [],
  };
  bless $self, $class;

  my @statements = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );
  for my $stmt (@statements) {
    $self->execute( $stmt );
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input10.txt';
my $cpu = Cpu->new( $input_file );

print "The signal strength is $cpu->{ sum }\n";

$cpu->print();

exit;
