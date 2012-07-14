#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';
use local::lib 'cpan';

use AI::Genetic;
use JSON::XS;
use Lifter;

use IO::Handle;
STDIN->autoflush(1);
STDOUT->autoflush(1);
  
my $input = <>;
exit unless $input;
chomp $input;

# we don't use world... but if we did...
my $world = decode_json($input);

# Now we use a GA to decide what moves to do
my $moves = run_ga();

while(my $move = shift @$moves) {
  print STDERR "Move: $move\n";
  print "$move\n";
  <>;
}

print "A\n" while 1;

exit;

sub run_ga {
  my $ga = AI::Genetic->new(
    -fitness    => \&test_moves,
    -type       => 'listvector',
    -population => 100,
    -crossover  => 0.9,
    -mutation   => 0.02,
  );
  $ga->init([
    map { [qw/ U D L R W A /] } 0..20
  ]);
  $ga->evolve('rouletteTwoPoint', 10);
  my $best = $ga->getFittest;
  print STDERR "\nBest score = " . $best->score . "\n";
  print STDERR "Best genes = " . join('',$best->genes) . "\n";
  return $best->genes();
}

sub test_moves {
  my $genes = shift;
  my $new_world = $world;
  foreach my $move (@$genes) {
    $new_world = Lifter::robot_move($new_world, $move);
    $new_world = Lifter::check_ending($new_world);
    $new_world = Lifter::world_update($new_world);
    $new_world = Lifter::check_ending($new_world);
  }
  print STDERR $new_world->{score} . "\t";
  return $new_world->{score};
}

