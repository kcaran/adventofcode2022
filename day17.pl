#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

my $debug = 0;

my $size = 40;

{ package Square;

 sub hit {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   return $tetris->{ grid }[$y][$x]
	|| $tetris->{ grid }[$y+1][$x]
	|| $tetris->{ grid }[$y+1][$x+1]
	|| $tetris->{ grid }[$y][$x+1];
  }

 sub fill {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   $tetris->{ grid }[$y][$x] = '#';
   $tetris->{ grid }[$y+1][$x] = '#';
   $tetris->{ grid }[$y+1][$x+1] = '#';
   $tetris->{ grid }[$y][$x+1] = '#';

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
	height => 2,
	width => 2,
  };
  bless $self, $class;

  return $self;
 }
};

{ package Vbar;

 sub hit {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   return grep { $tetris->{ grid }[$_][$x] } ($y ... $y + 3);
  }

 sub fill {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   for ($y .. $y + 3) {
     $tetris->{ grid }[$_][$x] = '#';
    }

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
	height => 4,
	width => 1,
  };
  bless $self, $class;

  return $self;
 }
};

{ package El;

 sub hit {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   return 1 if ($tetris->{ grid }[$y+1][$x+2]);
   return 1 if ($tetris->{ grid }[$y+2][$x+2]);
   return grep { $tetris->{ grid }[$y][$_] } ($x ... $x + 2);
  }

 sub fill {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   $tetris->{ grid }[$y+1][$x+2] = '#';
   $tetris->{ grid }[$y+2][$x+2] = '#';
   for ($x .. $x + 2) {
     $tetris->{ grid }[$y][$_] = '#';
    }

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
	height => 3,
	width => 3,
  };
  bless $self, $class;

  return $self;
 }
};

{ package Plus;

 sub hit {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   return 1 if ($tetris->{ grid }[$y][$x+1]);
   return 1 if ($tetris->{ grid }[$y+2][$x+1]);
   return grep { $tetris->{ grid }[$y+1][$_] } ($x ... $x + 2);
  }

 sub fill {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   $tetris->{ grid }[$y+2][$x+1] = '#';
   $tetris->{ grid }[$y][$x+1] = '#';
   for ($x .. $x + 2) {
     $tetris->{ grid }[$y+1][$_] = '#';
    }

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
	height => 3,
	width => 3,
  };
  bless $self, $class;

  return $self;
 }
};

{ package Hbar;

 sub hit {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   return grep { $tetris->{ grid }[$y][$_] } ($x .. $x + 3);
  }

 sub fill {
   my ($self, $tetris, $y, $x) = @_;

   $y = $y - $tetris->{ offset };
   for ($x .. $x + 3) {
     $tetris->{ grid }[$y][$_] = '#';
    }

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
	height => 1,
	width => 4,
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

 sub blow {
   my ($self, $piece, $y, $x) = @_;

   my $new_x = $x;
   my $width = $piece->{ width };
   my $dir = substr( $self->{ jet }, $self->{ jetpos }, 1 );
   $self->{ jetpos } = ($self->{ jetpos } + 1) % length( $self->{ jet } );
   $new_x++ if ($dir eq '>' && $x < 7 - $width);
   $new_x-- if ($dir eq '<' && $x > 0);
   $new_x = $x if ($piece->hit( $self, $y, $new_x ));

print "$self->{ jetpos }, $dir, $y, $x\n" if ($debug);

   return $new_x;
  }

 sub move {
   my ($self) = @_;

   my $piece = $self->{ pieces }[ $self->{ piecenum } ];

   my $height = $piece->{ height };
   my $x = 2;
   my $y = $self->{ max_y } + 3;
   my $hit = 0;
   while (!$hit) {
     my $new_x = $self->blow( $piece, $y, $x );
     $x = $new_x unless ($piece->hit( $self, $y, $new_x ));
     my $new_y = $y - 1;
     $hit = ($new_y < 0) || $piece->hit( $self, $new_y, $x );
     $y = $new_y unless ($hit);
    }

   $piece->fill( $self, $y, $x );

   $self->{ max_y } = $y + $height if ($y + $height > $self->{ max_y });

   $self->{ piecenum } = ($self->{ piecenum } + 1) % @{ $self->{ pieces } };

   while (@{ $self->{ grid } } > $size) {
     $self->{ offset }++;
     shift @{ $self->{ grid } };
    }

   return $self;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
	jet => $input,
	jetpos => 0,
	offset => 0,
	grid => [],
    max_y => 0,
    pieces => [ Hbar->new(), Plus->new(), El->new(), Vbar->new(), Square->new() ],
    piecenum => 0,
    cycle => {},
  };
  bless $self, $class;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input17.txt';
my $input = Path::Tiny::path( $input_file )->slurp_utf8( { chomp => 1 } );
chomp $input;
my $rocks = $ARGV[1] || 2022;

my $tetris = Tetris->new( $input );

my $found = 0;
my $count = 0;
my $cycle;
while (!$found && $count < $rocks) {
  $tetris->move();
  print $tetris->print() if ($debug);
  $cycle = $tetris->{ piecenum } . ',' . $tetris->{ jetpos };
  #
  # Note: If I used the first cycle I came across, this won't work.
  # Someone else used the $count > 1000 and I stole it. :-(
  #
  if ($count > 1000) {
    $found = $tetris->{ cycle }{ $cycle };
    $tetris->{ cycle }{ $cycle } = "$count,$tetris->{ max_y }" unless ($tetris->{ cycle }{ $cycle });
   }
  $count++ unless ($found);
 }

# Now calculate the cycles
my $height;
if ($found) {
print "KAC: $count: $cycle\n";
  my ($ocount, $oy) = split( ',', $tetris->{ cycle }{ $cycle } );
  my $loops = int( ($rocks - $ocount) / ($count - $ocount) );
  my $extras = ($rocks - $ocount - 1) % ($count - $ocount);
  my $loop_height = ($tetris->{ max_y } - $oy);
  my $curr_y = $tetris->{ max_y };
  for (0 .. $extras - 1) {
     $tetris->move();
    }
  my $diff = $tetris->{ max_y } - $curr_y;
  $height = $oy + ($loops * $loop_height) + $diff;
 }
else {
  $height = $tetris->{ max_y };
 }

print $tetris->print();
print "The tower is $height units tall after $rocks rocks fall\n";

exit;
