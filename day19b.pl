#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;
use Storable qw( dclone );

my $minutes = 32;

{ package Blueprint;

 sub next {
  my ($self) = @_;

  my $new = [ Storable::dclone( $self ) ];
  my $ore = $self->{ ore }{ bots };
  my $clay = $self->{ clay }{ bots };
  my $obs = $self->{ obs }{ bots };
  my $geo = $self->{ geo }{ bots };
  if (($self->{ ore }{ count } >= $self->{ geo }{ ore })
   && ($self->{ obs }{ count } >= $self->{ geo }{ obs })) {
    my $clone = Storable::dclone( $self );
    $clone->{ geo }{ bots }++;
    $clone->{ ore }{ count } -= $self->{ geo }{ ore };
    $clone->{ obs }{ count } -= $self->{ geo }{ obs };
    push @{ $new }, $clone;
   }
  if (($self->{ ore }{ count } >= $self->{ obs }{ ore })
   && ($self->{ clay }{ count } >= $self->{ obs }{ clay })) {
    my $clone = Storable::dclone( $self );
    $clone->{ obs }{ bots }++;
    $clone->{ ore }{ count } -= $self->{ obs }{ ore };
    $clone->{ clay }{ count } -= $self->{ obs }{ clay };
    push @{ $new }, $clone;
   }
  if ($self->{ ore }{ count } >= $self->{ clay }{ ore }) {
    my $clone = Storable::dclone( $self );
    $clone->{ clay }{ bots }++;
    $clone->{ ore }{ count } -= $self->{ clay }{ ore };
    push @{ $new }, $clone;
   }
  if ($self->{ ore }{ count } >= $self->{ ore }{ ore }) {
    my $clone = Storable::dclone( $self );
    $clone->{ ore }{ bots }++;
    $clone->{ ore }{ count } -= $self->{ ore }{ ore };
    push @{ $new }, $clone;
   }

  for my $b (@{ $new }) {
    $b->{ ore }{ count } += $ore;
    $b->{ clay }{ count } += $clay;
    $b->{ obs }{ count } += $obs;
    $b->{ geo }{ count } += $geo;
    $b->{ round }++;
   }

  return $new;
 }

 sub geode {
   my ($self) = @_;

   my $prints = [ $self ];
   for my $i (1..$minutes) {
print "minute $i, ", scalar( @{ $prints } ), "\n";
     my @new;
     for my $b (@{ $prints }) {
       push @new, @{ $b->next() };
       next;
      }
     @new = sort {
		$b->{ geo }{ bots } <=> $a->{ geo }{ bots }
		|| $b->{ obs }{ bots } <=> $a->{ obs }{ bots }
		|| $b->{ clay }{ bots } <=> $a->{ clay }{ bots }
		|| $b->{ ore }{ bots } <=> $a->{ ore }{ bots }
		|| $b->{ geo }{ count } <=> $a->{ geo }{ count }
		|| $b->{ obs }{ count } <=> $a->{ obs }{ count }
		|| $b->{ ore }{ count } <=> $a->{ ore }{ count }
		|| $b->{ clay }{ count } <=> $a->{ clay }{ count }
	} @new;

     # Grab the first few best options to prevent too many test cases.
     # I could do more if I could find counts that are all smaller
     my %found;
     $prints = [];
     for my $b (@new) {
        my $bots = join( ',', ($b->{ geo }{ bots }, $b->{ obs }{ bots }, $b->{ clay }{ bots }, $b->{ ore }{ bots }) );
        $found{ $bots } ||= 0;
        push @{ $prints }, $b unless ($found{ $bots } > 12);
        $found{ $bots }++;
       }
    }

   my $max_geodes = 0;
   for my $b (@{ $prints }) {
     if ($b->{ geo }{ count } > $max_geodes) {
       $max_geodes = $b->{ geo }{ count };
      }
    }

   return $max_geodes;
  }

 sub new {
  my ($class, $input) = @_;
  my $self = {
    round => 0,
    ore => { count => 0, bots => 1},
    clay => { count => 0, bots => 0 },
    obs => { count => 0, bots => 0 },
    geo => { count => 0, bots => 0 },
  };
  bless $self, $class;

  my ($num, $ore, $clay, $obs_ore, $obs_clay, $geo_ore, $geo_obs) = $input =~ /^Blueprint (\d+): (?:.*?)(\d+)\sore. (?:.*?)(\d+)\sore. (?:.*?)(\d+)\sore and (?:.*?)(\d+)\sclay. (?:.*?)(\d+)\sore and (?:.*?)(\d+)\sobsidian.$/ or die "Illegal blueprint $input\n";
  $self->{ num } = $num;
  $self->{ ore }{ ore } = $ore;
  $self->{ clay }{ ore } = $clay;
  $self->{ obs }{ ore } = $obs_ore;
  $self->{ obs }{ clay } = $obs_clay;
  $self->{ geo }{ ore } = $geo_ore;
  $self->{ geo }{ obs } = $geo_obs;

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input19.txt';
my @lines = Path::Tiny::path( $input_file )->lines_utf8( { chomp => 1 } );
my @blueprints;
for my $bp (@lines) {
  push @blueprints, Blueprint->new( $bp );
 }

my $quality = 1;
for my $i (0 .. 2) {
  my $geode = $blueprints[$i]->geode();
  print "Blueprint ", $i + 1, " can produce $geode\n";
  $quality *= $geode;
 }

print "The quality sum is $quality\n";

exit;
