#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package El;

 sub blow {
   my ($self, $tetris, $y, $x) = @_;

   my $new_x = $x;
   my $width = 3;
   my $dir = substr( $tetris->{ jet }, $tetris->{ jetpos }, 1 );
   $tetris->{ jetpos } = ($tetris->{ jetpos } + 1) % length( $tetris->{ jet } );
   $new_x++ if ($dir eq '>' && $x < 7 - $width);
   $new_x-- if ($dir eq '<' && $x > 0);
   $new_x = $x if ($self->hit( $tetris, $y, $new_x ));

print "$dir, $y, $x, $new_x\n";
   return $new_x;
  }

 sub hit {
   my ($self, $tetris, $y, $x) = @_;

   return grep { $tetris->{ grid }[$y][$_] } ($x ... $x + 2);
   return 1 if ($tetris->{ grid }[$y+1][$x+2]);
   return 1 if ($tetris->{ grid }[$y+2][$x+2]);
  }

 sub move {
   my ($self, $tetris) = @_;

   my $height = 3;
   my $x = 2;
   my $y = $tetris->{ max_y } + 3;
   my $hit = 0;
   while (!$hit) {
     my $new_x = $self->blow( $tetris, $y, $x );
     $x = $new_x unless ($self->hit( $tetris, $y, $new_x ));
     my $new_y = $y - 1;
     $hit = $self->hit( $tetris, $new_y, $x );
     $y = $new_y unless ($hit);
     $hit = 1 if ($y == 0);
    }

   $tetris->{ grid }[$y+1][$x+2] = '#';
   $tetris->{ grid }[$y+2][$x+2] = '#';
   for ($x .. $x + 2) {
     $tetris->{ grid }[$y][$_] = '#';
    }

   $tetris->{ max_y } = $y + $height if ($y + $height > $tetris->{ max_y });

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
  };
  bless $self, $class;

  return $self;
 }
};

{ package Plus;

 sub blow {
   my ($self, $tetris, $y, $x) = @_;

   my $new_x = $x;
   my $width = 3;
   my $dir = substr( $tetris->{ jet }, $tetris->{ jetpos }, 1 );
   $tetris->{ jetpos } = ($tetris->{ jetpos } + 1) % length( $tetris->{ jet } );
   $new_x++ if ($dir eq '>' && $x < 7 - $width);
   $new_x-- if ($dir eq '<' && $x > 0);
   $new_x = $x if ($self->hit( $tetris, $y, $new_x ));

   return $new_x;
  }

 sub hit {
   my ($self, $tetris, $y, $x) = @_;

   return 1 if ($tetris->{ grid }[$y][$x+1]);
   return grep { $tetris->{ grid }[$y+1][$_] } ($x ... $x + 2);
   return 1 if ($tetris->{ grid }[$y+2][$x+1]);
  }

 sub move {
   my ($self, $tetris) = @_;

   my $height = 3;
   my $x = 2;
   my $y = $tetris->{ max_y } + 3;
   my $hit = 0;
   while (!$hit) {
     my $new_x = $self->blow( $tetris, $y, $x );
     $x = $new_x unless ($self->hit( $tetris, $y, $new_x ));
     my $new_y = $y - 1;
     $hit = $self->hit( $tetris, $new_y, $x );
     $y = $new_y unless ($hit);
     $hit = 1 if ($y == 0);
    }

   $tetris->{ grid }[$y+2][$x+1] = '#';
   $tetris->{ grid }[$y][$x+1] = '#';
   for ($x .. $x + 2) {
     $tetris->{ grid }[$y+1][$_] = '#';
    }

   $tetris->{ max_y } = $y + $height if ($y + $height > $tetris->{ max_y });

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
  };
  bless $self, $class;

  return $self;
 }
};

{ package Hbar;

 sub blow {
   my ($self, $tetris, $y, $x) = @_;

   my $new_x = $x;
   my $width = 4;
   my $dir = substr( $tetris->{ jet }, $tetris->{ jetpos }, 1 );
   $tetris->{ jetpos } = ($tetris->{ jetpos } + 1) % length( $tetris->{ jet } );
   $new_x++ if ($dir eq '>' && $x < 7 - $width);
   $new_x-- if ($dir eq '<' && $x > 0);
   $new_x = $x if ($self->hit( $tetris, $y, $new_x ));

   return $new_x;
  }

 sub hit {
   my ($self, $tetris, $y, $x) = @_;

   return grep { $tetris->{ grid }[$y][$_] } ($x ... $x + 3);
  }

 sub move {
   my ($self, $tetris) = @_;

   my $height = 1;
   my $width = 4;
   my $x = 2;
   my $y = $tetris->{ max_y } + 3;
   my $hit = 0;
   while (!$hit) {
     my $new_x = $self->blow( $tetris, $y, $x );
     $x = $new_x unless ($self->hit( $tetris, $y, $new_x ));
     my $new_y = $y - 1;
     $hit = $self->hit( $tetris, $new_y, $x );
     $y = $new_y unless ($hit);
     $hit = 1 if ($y == 0);
    }

   for ($x .. $x + 3) {
     $tetris->{ grid }[$y][$_] = '#';
    }

   $tetris->{ max_y } = $y + $height if ($y + $height > $tetris->{ max_y });

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
  };
  bless $self, $class;

  return $self;
 }
};

{ package Tetris;

 sub print {
   my ($self) = @_;

   my $map = "\n";
   for my $y (reverse( 0 .. @{ $self->{ grid } } - 1)) {
     my $row = $self->{ grid }[$y];
     $map .= '|';
     for my $col (0..6) {
       $map .= $row->[$col] ? '#' : '.';
      }
     $map .= "|\n";
    }
   $map .= "---------\n";

   return $map;
  }

 sub move {
   my ($self) = @_;

   my $piece = $self->{ pieces }[ $self->{ piecenum } ];
   $piece->move( $self );
   $self->{ piecenum } = ($self->{ piecenum } + 1) % @{ $self->{ pieces } };

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
	jet => $input,
	jetpos => 0,
	grid => [],
    max_y => 0,
    pieces => [ Hbar->new(), Plus->new(), El->new() ],
    piecenum => 0,
  };
  bless $self, $class;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input17.txt';
my $input = Path::Tiny::path( $input_file )->slurp_utf8();

my $tetris = Tetris->new( $input );
$tetris->move();
print $tetris->print();
$tetris->move();
print $tetris->print();
$tetris->move();
print $tetris->print();
exit;
