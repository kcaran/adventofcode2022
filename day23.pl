#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Grid;

 sub alone {
   my ($self, $elf) = @_;

   my ($elf_y, $elf_x) = split( ',', $elf );
   for my $y (-1 .. 1) {
     for my $x (-1 .. 1) {
       next if ($y == 0 && $x == 0);
       return if ($self->{ elves }{ ($elf_y + $y) . "," . ($elf_x + $x) });
      }
    }
   return 1;
  }

 sub print {
   my ($self) = @_;

   my $grid = "\n";
   for my $y ($self->{ min_y } .. $self->{ max_y }) {
     for my $x ($self->{ min_x } .. $self->{ max_x }) {
       $grid .= $self->{ elves }{ "$y,$x" } ? '#' : '.';
      }
      $grid .= "\n";
     }
    return $grid;
  }

 sub count {
   my ($self) = @_;

   my $count = 0;
   for my $y ($self->{ min_y } .. $self->{ max_y }) {
     for my $x ($self->{ min_x } .. $self->{ max_x }) {
       $count++ unless ($self->{ elves }{ "$y,$x" });
      }
     }
    return $count;
  }

 sub valid {
   my ($self, $elf, $dir) = @_;

   my ($elf_y, $elf_x) = split( ',', $elf );
   if ($dir->[0] == 0) {
     $elf_x += $dir->[1];
     for my $y (-1 .. 1) {
       return if ($self->{ elves }{ ($elf_y + $y) . ",$elf_x" });
      }
    }
   else {
     $elf_y += $dir->[0];
     for my $x (-1 .. 1) {
       return if ($self->{ elves }{ "$elf_y," . ($elf_x + $x) });
      }
    }

   return "$elf_y,$elf_x";
  }

 sub move {
   my ($self, $elf) = @_;

   return $elf if ($self->alone( $elf ));
   for my $dir (0..3) {
     my $new = $self->valid( $elf, $self->{ dirs }[$dir] );
     return $new if ($new);
    }

   return $elf;
  }

 sub new_elf {
   my ($self, $elf) = @_;
   my ($elf_y, $elf_x) = split( ',', $elf );
   $self->{ min_y } = $elf_y if ($elf_y < $self->{ min_y });
   $self->{ max_y } = $elf_y if ($elf_y > $self->{ max_y });
   $self->{ min_x } = $elf_x if ($elf_x < $self->{ min_x });
   $self->{ max_x } = $elf_x if ($elf_x > $self->{ max_x });
   $self->{ elves }{ $elf } = 1;
  }

 sub round {
   my ($self) = @_;

   # Get the moves for the elves
   my %moves;
   for my $elf (keys %{ $self->{ elves } }) {
     push @{ $moves{ $self->move( $elf ) } }, $elf;
    }

   # Swap the min and max and redo
   ($self->{ min_y }, $self->{ max_y }) = ($self->{ max_y }, $self->{ min_y } );
   ($self->{ min_x }, $self->{ max_x }) = ($self->{ max_x }, $self->{ min_x } );
   my $old_keys = join( '', sort { $a cmp $b } keys %{ $self->{ elves } } );
   # Move them to their new positions
   $self->{ elves } = {};
   for my $m (keys %moves) {
     if (@{ $moves{ $m } } == 1) {
       $self->new_elf( $m );
      }
     else {
       for my $elf (@{ $moves{ $m } }) {
         $self->new_elf( $elf );
        }
      }
    }
   my $new_keys = join( '', sort { $a cmp $b } keys %{ $self->{ elves } } );

   my $dir = shift @{ $self->{ dirs } };
   push @{ $self->{ dirs } }, $dir;

   return ($old_keys eq $new_keys);
  }

 sub new {
  my ($class, $input_file) = @_;
  my $self = {
    elves => {},
    min_y => 0,
    max_y => 0,
    min_x => 0,
    max_x => 0,
    dirs => [ [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ],
  };
  bless $self, $class;

  my @lines = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );
  my $y = 0;
  $self->{ min_x } = length( $lines[0] );
  for my $row (@lines) {
    if ($row =~ /^\.+$/) {
      $y++ unless ($y == 0);
      next;
     }
    for my $x (0 .. length( $row )) {
      if (substr( $row, $x, 1 ) eq '#') {
        $self->{ elves }{ "$y,$x" } = 1;
        $self->{ min_x } = $x if ($self->{ min_x } > $x);
        $self->{ max_x } = $x if ($self->{ max_x } < $x);
       }
     }
    $self->{ max_y } = $y++;
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input23.txt';
my $grid = Grid->new( $input_file );

my $moves = 10;
for my $i (1 .. $moves) {
   $grid->round();
  }

print "After $moves moves there are ", $grid->count(), " empty spaces.\n";

my $none_moved;
while (!$none_moved) {
   $moves++;
   $none_moved = $grid->round();
  }

print "No more elves move after round $moves\n";
exit;
