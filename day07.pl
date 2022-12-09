#!/usr/bin/env perl

use feature ':5.16';

use strict;
use warnings;
use utf8;

use Path::Tiny;

{ package Filesystem;

sub delete {
  my ($self) = @_;

  my $needed = $self->size(0) - 40000000;
  my @order = sort { $self->size( $a ) <=> $self->size( $b ) } (0 .. @{ $self->{ dirs } } - 1);
  my $idx = 0;
  while ($self->size( $order[$idx] ) <= $needed) {
    $idx++;
   }
  return $self->size( $order[$idx] );
 }

sub smallsum {
  my ($self, $dir) = @_;

  my $sum = 0;
  for my $dir (0 .. @{ $self->{ dirs } } - 1) {
    my $dirsize = $self->size( $dir );
    $sum += $dirsize if ($dirsize <= 100000);
   }

  return $sum;
 }

sub size {
  my ($self, $dir) = @_;

  unless ($self->{ dirs }[$dir]{ size }) {
    my $size = 0;
    for my $file (@{ $self->{ dirs }[$dir]{ files } }) {
      $size += $file->{ size };
     }
    for my $dir (@{ $self->{ dirs }[$dir]{ children } }) {
      $size += $self->size( $dir );
     }
    $self->{ dirs }[$dir]{ size } = $size;
    }

  return $self->{ dirs }[$dir]{ size };
 }

sub ls {
  my ($self) = @_;

  my $children = $self->{ dirs }[$self->{ cwd }]{ children };
  while (@{ $self->{ lines } } && substr( $self->{ lines }[0], 0, 1 ) ne '$') {
    my $child = shift @{ $self->{ lines } };
    if ($child =~ /^dir (\S+)/) {
      my $dir = $1;
      die "Found $dir" if (grep { $self->{ dirs }[$_]{ name } eq $dir } @{ $children });
      push @{ $self->{ dirs } }, { name => $dir, parent => $self->{ cwd }, children => [], files => [] };
      my $index = scalar @{ $self->{ dirs } } - 1;
      push @{ $self->{ dirs }[$self->{ cwd }]{ children } }, $index;
     }
    elsif ($child =~ /^(\d+)\s(.*?)\s?$/) {
      my ($size, $file) = ($1, $2);
      die "Found $file" if (grep { $_->{ name } eq $file } @{ $self->{ dirs }[$self->{ cwd }]{ files } });
      push @{ $self->{ dirs }[$self->{ cwd }]{ files } }, { name => $file, size => $size };
     }
    else {
      die "Invalid line $child\n";
     }
   }

  return $self;
 }

sub cd {
  my ($self, $arg) = @_;

  if ($arg eq '/') {
    $self->{ cwd } = 0;
   }
  elsif ($arg eq '..') {
    $self->{ cwd } = $self->{ dirs }[$self->{ cwd }]{ parent };
   }
  else {
    my $new;
    my @subs = @{ $self->{ dirs }[$self->{ cwd }]{ children } };
    do {
      my $sub = shift @subs;
      if ($self->{ dirs }[$sub]{ name } eq $arg) {
        $new = $sub;
        $self->{ cwd } = $new;
       }
    } until ($new);
   }

  return $self;
 }

sub new {
  my ($class, $input_file) = @_;

  my $self = {
    lines => [],
    cwd => 0,
    dirs => [{ name => '/', parent => 0, children => [], files => [] }],
  };

  $self->{ lines } = [ Path::Tiny::path( $input_file )->lines( { chomp => 1 } ) ];
  bless $self, $class;

  while (@{ $self->{ lines } }) {
    my $line = shift @{ $self->{ lines } };
    die "Invalid command: $line" unless ($line =~ /^\$\s(\S+)\s?(\S+)?/);
    my ($cmd, $arg) = ($1, $2);
    $self->cd( $arg ) if ($cmd eq 'cd');
    $self->ls( $arg ) if ($cmd eq 'ls');
   }

  return $self;
 }
}

my $input_file = $ARGV[0] || 'input07.txt';

my $filesystem = Filesystem->new( $input_file );

print "The root directory size is ", $filesystem->size( 0 ), "\n";

print "The small directory sum is ", $filesystem->smallsum(), "\n";

print "The directory to delete has size of ", $filesystem->delete(), "\n";

exit;
