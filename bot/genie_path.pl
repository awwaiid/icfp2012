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
    -mutation   => 0.02,
  );
  $ga->init([
    # map { [qw/ U U D D L L R R W S A /] } 0..200
    (map { [qw/ U D L R W /] } 0..50),
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
  my $path_score = path_score($new_world);
  $score += $path_score;
  
  if($new_world->{lambda_remain} == 0) {
    $score += 10_000;
  }

  if($new_world->{ending} eq 'WIN') {
    $score += 100_000;
  }

  debug "$score ";
  return $score; # - ($dist * 10);
}

use Graph;
sub path_score {
  my ($world) = @_;
  # print STDERR Lifter::map_to_string($world->{map});
  my $graph = world_to_graph($world);
  # print STDERR "Graph:\n$graph\n";
  my ($x, $y) = @{ $world->{robot_loc} };
  my @r = $graph->all_reachable("$x,$y");
  # say STDERR "Reachable from [$x,$y]: @r\n";
  my $lambda_count = 0;
  foreach my $p (@r) {
    my ($i, $j) = split(',', $p);
    if($world->{map}->[$i][$j] eq '\\') {
      $lambda_count++;
    }
  }
  my $ratio = ($world->{lambda_remain} && ($lambda_count / $world->{lambda_remain})) || 1;
  print STDERR "Lambda ratio: $ratio\n";
  return $ratio * 1000;
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
      if($cell =~ /[ \\.!A-IR]/) {
        if ( $x > 0 && $map->[$x - 1][$y] =~ /[ \\.OL!A-I]/ ) {
          $graph->add_edge("$x,$y", ($x - 1) . ",$y");
        }
        if ( $map->[$x + 1][$y] =~ /[ \\.OL!A-I]/ ) {
          $graph->add_edge("$x,$y", ($x + 1) . ",$y");
        }
        if ( $y > 0 && $map->[$x][$y - 1] =~ /[ \\.OL!A-I]/ ) {
          $graph->add_edge("$x,$y", "$x," . ($y - 1));
        }
        if ( $map->[$x][$y + 1] =~ /[ \\.OL!A-I]/ ) {
          $graph->add_edge("$x,$y", "$x," . ($y + 1));
        }
      }
      if($cell =~ /[A-I]/) {
        # ... trampolines
      }
    }
  }
  return $graph;

}

