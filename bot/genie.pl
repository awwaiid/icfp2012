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

sub debug {
  return;
  print STDERR $_ foreach @_;
}

# we don't use world... but if we did...
my $world = decode_json($input);
my $ga;


# Now we use a GA to decide what moves to do
eval {
  local $SIG{INT} = sub { die };
  run_ga();
};

my $moves = $ga->getFittest->genes;

if($@) {
  my $best = $ga->getFittest;
  debug "Interrupt!\n";
  debug "\nBest score = " . $best->score . "\n";
  debug "Best genes = " . join('',$best->genes) . "\n";
  print join('',$ga->getFittest->genes) . "\n";
  exit;
}
    

while(my $move = shift @$moves) {
  debug "Move: $move\n";
  print "$move\n";
  <>;
}

print "A\n" while 1;

exit;

sub run_ga {
  $ga = AI::Genetic->new(
    -fitness    => \&test_moves,
    -type       => 'listvector',
    -population => 50,
    -crossover  => 0.9,
    -mutation   => 0.03,
  );
  $ga->init([
    map { [qw/ U U D D L L R R W A /] } 0..100
  ]);
  # $ga->evolve('rouletteTwoPoint', 50);
  # $ga->evolve('tournamentUniform', 50);
  # $ga->evolve('tournamentTwoPoint', 50);
  # $ga->evolve('tournamentSinglePoint', 50);
  $ga->evolve('randomUniform', 50);
  my $best = $ga->getFittest;
  debug "\nBest score = " . $best->score . "\n";
  debug "Best genes = " . join('',$best->genes) . "\n";
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
    last if $new_world->{ending};
  }
  debug $new_world->{score} . "\t";
  return $new_world->{score};
}

