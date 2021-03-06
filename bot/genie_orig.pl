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
  # return;
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


sub maximize {
  my ($moves) = @_;
  my $local_world = $world;
  my @best_moves = ();
  my $max_score = -100000;
  my @moves_so_far = ();
  foreach my $move (@$moves) {
    push @moves_so_far, $move;
    $local_world = Lifter::eval_move($local_world, $move);
    if($local_world->{score} > $max_score) {
      $max_score = $local_world->{score};
      (@best_moves) = (@moves_so_far);
      debug "New best ($max_score): @best_moves\n";
    }
    my $abort_world = Lifter::eval_move($local_world, 'A');
    if($abort_world->{score} > $max_score) {
      debug "Abort is better!\n";
      $max_score = $abort_world->{score};
      (@best_moves) = (@moves_so_far, 'A');
      debug "New best ($max_score): @best_moves\n";
    }
  }
  return [@best_moves];
}

if($@) {
  debug "Interrupt!\n";
}

my $best = $ga->getFittest;
my $moves = scalar $best->genes;

debug "\nBest score = " . $best->score . "\n";
debug "Best genes = " . join('',$best->genes) . "\n";
my $best_genes = maximize($moves);
debug "Max genes  = " . join('',@$best_genes) . "\n";

if($@) {
  print join('',@$best_genes) . "\n";
  exit;
}


while(my $move = shift @$best_genes) {
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
    -mutation   => 0.02,
  );
  $ga->init([
    # map { [qw/ U U D D L L R R W S A /] } 0..200
    (map { [qw/ U D L R W /] } 0..200),
    [ 'A' ],
  ]);
  # $ga->evolve('rouletteTwoPoint', 1000);
  # $ga->evolve('tournamentUniform', 50);
  # $ga->evolve('tournamentTwoPoint', 1000);
  # $ga->evolve('tournamentSinglePoint', 50);
  $ga->evolve('randomUniform', 20);
  # $ga->evolve('randomSinglePoint', 1000);
  my $best = $ga->getFittest;
  debug "\nBest score = " . $best->score . "\n";
  debug "Best genes = " . join('',$best->genes) . "\n";
  return $best->genes();
}

sub test_moves {
  my $genes = shift;
  my $new_world = $world;
  foreach my $move (@$genes) {
    $new_world = Lifter::eval_move($new_world, $move);
    last if $new_world->{ending};
  }

  my $score = $new_world->{score};
  # my $path_score = path_score($new_world);

  debug "$score ";
  return $score; # - ($dist * 10);
}

use Graph;
sub path_score {
  my ($world) = @_;
  my $graph = world_to_graph($world);
  print STDERR "Graph:\n$graph\n";
}

sub world_to_graph {
  my ($world) = @_;
  my $map = $world->{map};
  my $graph = Graph->new;
  my $width = scalar @$map;
  my $height = scalar @{ $map->[0] };
  for(my $y = 0; $y < $height; $y++) {
    for(my $x = 0; $x < $width; $x++) {
      my $cell = $map->[$x][$y];
      if($cell =~ /[ \\.OL!A-L]/) {
        if ( ! $x || $map->[$x - 1][$y] =~ /[ \\.OL!A-L]/ ) {
          $graph->add_edge("$x,$y", ($x - 1) . ",$y");
        }
        if ( $map->[$x + 1][$y] =~ /[ \\.OL!A-L]/ ) {
          $graph->add_edge("$x,$y", ($x + 1) . ",$y");
        }
        if ( ! $y || $map->[$x][$y - 1] =~ /[ \\.OL!A-L]/ ) {
          $graph->add_edge("$x,$y", "$x," . $y - 1);
        }
        if ( $map->[$x][$y + 1] =~ /[ \\.OL!A-L]/ ) {
          $graph->add_edge("$x,$y", "$x," . $y + 1);
        }
      } elsif($cell =~ /[A-I]/) {
        # ... trampolines
      }
    }
  }

}

