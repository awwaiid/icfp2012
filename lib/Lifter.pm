package Lifter;

use v5.10;
use strict;
use warnings;
use File::Slurp;

sub load_map {
  my $source = shift;
  my @raw_map;

  @raw_map = map { [split //, $_] } read_file($source, { chomp => 1 });

  my $height = scalar @raw_map;

  my $map = [];
  for(my $y = 0; $y < @raw_map; $y++) {
    my $row = $raw_map[$y];
    for(my $x = 0; $x < @$row; $x++) {
      $map->[$x][$height - $y - 1] = $raw_map[$y]->[$x];
    }
  }
  return $map;
}

sub map_to_string {
  my $map = shift;
  my @raw_map = reverse @$map;
  my $out = '';

  my $width = scalar @$map;
  my $height = scalar @{ $map->[0] };
  for(my $y = $height - 1; $y >= 0; $y--) {
    for(my $x = 0; $x < $width; $x++) {
      $out .= $map->[$x][$y];
    }
    $out .= "\n";
  }

  return $out;
}

sub print_map {
  my $map = shift;
  print map_to_string($map);
  print "\n";
}

sub get_robot_loc {
  my $map = shift;

  my $width = scalar @$map;
  my $height = scalar @{ $map->[0] };

  for(my $y = 0; $y < $height; $y++) {
    for(my $x = 0; $x < $width; $x++) {
      return [$x, $y] if $map->[$x][$y] eq 'R';
    }
  }
}

sub get_lambda_count {
  my $map = shift;

  my $width = scalar @$map;
  my $height = scalar @{ $map->[0] };

  my $count = 0;
  for(my $y = 0; $y < $height; $y++) {
    for(my $x = 0; $x < $width; $x++) {
      $count++ if $map->[$x][$y] eq '\\';
    }
  }
  return $count;
}

sub check_ending {
  my ($map, $robot_loc) = @_;
  my ($x, $y) = @$robot_loc;
  if($map->[$x][$y+1] eq '+') {
    say "YOU WERE CRUSHED";
    exit;
  }
  # Flip the rocks back to stars
  $map = [
    map {
      [
        map { s/\+/*/ ; $_ } @$_
      ] 
    }
    @$map
  ];
  return $map;
}

sub map_update {
  my $map = shift;
  my $new_map = [];
  my $map_width = scalar @{$map->[0]};
  my $map_height = scalar @{$map};
  for(my $y = 0; $y < $map_height; $y++) {
    for(my $x = 0; $x < $map_width; $x++) {

      my $cell       = $map->[$x][$y];
      my $left       = $map->[$x-1][$y]   if $x > 0;
      my $right      = $map->[$x+1][$y]   if $x < $map_width - 1;
      my $down       = $map->[$x][$y-1]   if $y > 0;
      my $up         = $map->[$x][$y+1]   if $y < $map_height - 1;
      my $right_down = $map->[$x+1][$y-1] if $x < $map_width - 1 && $y > 0;
      my $left_down  = $map->[$x-1][$y-1] if $x > 0 && $y > 0;

      # Rocks fall down though empty space
      if($cell =~ /[*+]/ && $down eq ' ') {
        say STDERR "DOWN";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x][$y-1] = '+';
      }

      # Rocks on rocks flow down to the right
      elsif($cell =~ /[*+]/ && $down =~ /[*+]/ && $right eq ' ' && $right_down eq ' ') {
        say STDERR "rock-flow right";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x+1][$y-1] = '+';
      }
      
      # Rocks on rocks flow down to the left
      elsif($cell =~ /[*+]/ && $down =~ /[*+]/ && $left eq ' ' && $left_down eq ' ') {
        say STDERR "rock-flow left";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x-1][$y-1] = '+';
      }

      # Rocks on lambdas flow down to the right
      elsif($cell =~ /[*+]/ && $down eq '\\' && $right eq ' ' && $right_down eq ' ') {
        say STDERR "lambda-flow right";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x+1][$y-1] = '+';
      }
      
      # All other cases... cell remains!
      else {
        $new_map->[$x][$y] = $cell;
      }
    }
  }
  return $new_map;
}

sub robot_move {
  my ($map, $robot_loc, $move) = @_;
  $move = uc $move;
  my ($x, $y) = @$robot_loc;
  my $new_loc = [@$robot_loc];
  if($move eq 'U') {
    if($map->[$x][$y+1] eq ' '
      || $map->[$x][$y+1] eq '.'
      || $map->[$x][$y+1] eq '\\'
    ) {
      $map->[$x][$y] = ' ';
      $map->[$x][$y+1] = 'R';
      $new_loc = [$x, $y+1];
    }
    if($map->[$x][$y+1] eq 'o') {
      print "You win!\n";
      exit;
    }
  }
  if($move eq 'D') {
    if($map->[$x][$y-1] eq ' '
      || $map->[$x][$y-1] eq '.'
      || $map->[$x][$y-1] eq '\\'
    ) {
      $map->[$x][$y] = ' ';
      $map->[$x][$y-1] = 'R';
      $new_loc = [$x, $y-1];
    }
    if($map->[$x][$y-1] eq 'o') {
      print "You win!\n";
      exit;
    }
  }
  if($move eq 'R') {
    if($map->[$x+1][$y] eq ' '
      || $map->[$x+1][$y] eq '.'
      || $map->[$x+1][$y] eq '\\'
    ) {
      $map->[$x][$y] = ' ';
      $map->[$x+1][$y] = 'R';
      $new_loc = [$x+1, $y];
    }
    if($map->[$x+1][$y] eq 'o') {
      print "You win!\n";
      exit;
    }
    if($map->[$x+1][$y] =~ /[*+]/ && $map->[$x+2][$y] eq ' ') {
      $map->[$x][$y] = ' ';
      $map->[$x+1][$y] = 'R';
      $map->[$x+2][$y] = '*';
      $new_loc = [$x+1, $y];
    }
  }
  if($move eq 'L') {
    if($map->[$x-1][$y] eq ' '
      || $map->[$x-1][$y] eq '.'
      || $map->[$x-1][$y] eq '\\'
    ) {
      $map->[$x][$y] = ' ';
      $map->[$x-1][$y] = 'R';
      $new_loc = [$x-1, $y];
    }
    if($map->[$x-1][$y] eq 'o') {
      print "You win!\n";
      exit;
    }
    if($map->[$x-1][$y] =~ /[*+]/ && $map->[$x-2][$y] eq ' ') {
      $map->[$x][$y] = ' ';
      $map->[$x-1][$y] = 'R';
      $map->[$x-2][$y] = '*';
      $new_loc = [$x-1, $y];
    }
  }
  return ($map, $new_loc);
}

1;

