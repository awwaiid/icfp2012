#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';
use local::lib 'cpan';

use AI::Genetic;
use JSON::XS;
use Lifter;
use Text::Levenshtein qw(distance);

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

my $map_height = scalar @{$world->{map}->[0]};
my $map_width  = scalar @{$world->{map}};

my $best_score = -10000;
my $best_genes = [];
my $best_steps = '';

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
  print join('',$ga->getFittest->genes) . "A\n";
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
    # -fitness    => \&test_moves,
    -fitness    => \&test_pattern_moves,
    -type       => 'listvector',
    -population => 100,
    -crossover  => 0.9,
    -mutation   => 0.02,
  );
  # $ga->init([
    # (map { [qw/ U D L R W S /] } 0..400), # A
    # [ 'A' ],
  # ]);
  $ga->init([
    map {
      # [qw/ . * _ O L W \\ ! /, '#', 1..9, 'A'..'L'],
      [qw/ . * _ O L W \\ /, '#'],
      [qw/ . * _ O L W \\ /, '#'],
      [qw/ . * _ O L W \\ /, '#'],
      [qw/ . * _ O L W \\ /, '#'],
      [qw/ . * _ O L W \\ /, '#'],
      [qw/ . * _ O L W \\ /, '#'],
      [qw/ . * _ O L W \\ /, '#'],
      [qw/ . * _ O L W \\ /, '#'],
      [qw/ U D L R W A /],
    } 1..20
  ]);
  # $ga->evolve('rouletteTwoPoint', 1000);
  # $ga->evolve('tournamentUniform', 50);
  # $ga->evolve('tournamentTwoPoint', 1000);
  $ga->evolve('tournamentSinglePoint', 50);
  # $ga->evolve('randomUniform', 20);
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
    $new_world = Lifter::robot_move($new_world, $move);
    $new_world = Lifter::check_ending($new_world);
    $new_world = Lifter::world_update($new_world);
    $new_world = Lifter::check_ending($new_world);
    last if $new_world->{ending};
  }

  # my $path_bonus = get_path_bonus($new_world);

  debug $new_world->{score} . "\t";
  my ($x, $y) = @{$new_world->{robot_loc}};
  my ($i, $j) = @{Lifter::get_lift_loc($new_world->{map})};

  # my $dist = sqrt( ($x - $i) ** 2 + ($y - $j) ** 2 );
  # debug "Distance $dist\n";
  return $new_world->{score}; # - ($dist * 10);
}

sub pattern_to_string {
  my ($pat,$move) = @_;
  my @pat = split(//,$pat);
  return "
$pat[0]$pat[1]$pat[2]
$pat[3]R$pat[4] -> $move
$pat[5]$pat[6]$pat[7]
";
}

sub print_pattern {
  print STDERR pattern_to_string(@_);
}

sub print_pattern_geneome {
  my ($genes) = @_;
  my @genes = @$genes;
  my $gene_pat = {};
  while(@genes) {
    my $p = join('', splice(@genes,0,8));
    my $move = shift @genes;
    print_pattern($p, $move);
  }
}

sub test_pattern_moves {
  my $genes = shift;
  my $new_world = $world;

  my @genes = @$genes;
  my $gene_pat = {};
  while(@genes) {
    my $p = join('', splice(@genes,0,8));
    $gene_pat->{$p} = shift @genes;
  }

  my $actual_moves = '';
  for (1..20) {
    my $m = $new_world->{map};
    my @pat;
    my ($x, $y) = @{ $new_world->{robot_loc} };

    my $pat = '';
    for my $i (-1..1) {
      for my $j (-1..1) {
        my $xi = $x + $i;
        my $yj = $y + $j;
        # say "... checking $xi,$yj";
        if($xi >= 0 && $xi < $map_width && $yj >= 0 && $yj < $map_height) {
          next if $xi == $x && $yj == $y;
          $pat .= $new_world->{map}->[$xi][$yj];
        } else {
          $pat .= '#'; # everything else is brick
        }
      }
    }

    # Go through each gene to see if we have a match
    my ($best_match, $best_distance);
    $best_distance = 100;
    foreach my $p (keys %$gene_pat) {
      my $d = distance($p,$pat);
      if($d < $best_distance || !$best_match) {
        $best_match = $p;
        $best_distance = $d;
      }
    }


    my $move = $gene_pat->{$best_match};
    # print_pattern($best_match, $move);
    # $actual_moves .= $move;
    $actual_moves .= pattern_to_string($best_match, $move);

    $new_world = Lifter::robot_move($new_world, $move);
    $new_world = Lifter::check_ending($new_world);
    $new_world = Lifter::world_update($new_world);
    $new_world = Lifter::check_ending($new_world);
    last if $new_world->{ending};
  }

  if($new_world->{score} > $best_score) {
    $best_score = $new_world->{score};
    $best_genes = [ @$genes ];
    debug "\n\nNew best score: $best_score\n";
    debug "Moves:\n$actual_moves\n";
    debug "------- all patterns -------\n";
    print_pattern_geneome($genes);
  } else {
    debug $new_world->{score} . " ";
  }

  return $new_world->{score}; # - ($dist * 10);
}



# sub get_path_bonus {
  # my $world = shift;
  # my $graph = Graph->new;

  # my $map = $world->{map};

  # my $width = scalar @$map;
  # my $height = scalar @{ $map->[0] };

  # my $add_directional_edges = sub {
    # my ($x, $y) = @_;
    # foreach my $dest ([$x+1,$y,'R'],[$x-1,$y,'L'],[$x,$y-1,'D'],[$x,$y+1,'U']) {
      # my ($i, $j, $d) = @$dest;
      # next if $i < 0 || $j < 0 || $i >= $width || $j >= $height;
      # my $t = $map->[$i][$j];
      # if($t =~ /[\\ .OA-L]/) {
        # $graph->add_edge("$x,$y", "$i,$j", $d);
      # }
    # }
  # }

  # my $count = 0;
  # for(my $y = 0; $y < $height; $y++) {
    # for(my $x = 0; $x < $width; $x++) {
      # my $cell = $map->[$x][$y];
      # if($cell =~ /[\\ .]/) {
        # $add_directional_edges->($x,$y);
      # }
    # }
  # }

  # return $count;
# }


