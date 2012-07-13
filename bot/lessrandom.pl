#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use IO::Scalar;
use JSON::XS;
use lib 'lib';
use Lifter;
use List::Util qw( max );

STDIN->autoflush(1);
STDOUT->autoflush(1);

# my @moves = qw( L R U D W );
my @moves = qw( L R U D );

while(1) {
  my $input = <>;
  exit unless $input;
  chomp $input;

  # we don't use world... but if we did...
  my $world = decode_json($input);

  my $choices = {};
  foreach my $move (@moves) {
    my $new_world;
    $new_world = Lifter::robot_move($world, $move);
    $new_world = Lifter::check_ending($new_world);
    $new_world = Lifter::world_update($new_world);
    $new_world = Lifter::check_ending($new_world);
    $choices->{$move} = $new_world->{score};
  }
  
  my %by_score = reverse %$choices;
  my $best_score = max values %$choices;
  my $move = $by_score{$best_score};
  print STDERR "My move: $move\n";
  print "$move\n";
}

