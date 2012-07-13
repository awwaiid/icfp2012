package Lifter;

use v5.10;
use strict;
use warnings;
use File::Slurp;


sub load_map {
  my $source = shift;
  my @raw_map;

  @raw_map = map { [split //, $_] } read_file($source, { chomp => 1 });
  my $map = [reverse @raw_map];
  return $map;
}


sub print_map {
  my $map = shift;
  my @raw_map = reverse @$map;
  foreach my $row (@raw_map) {
    foreach my $col (@$row) {
      print $col;
    }
    print "\n";
  }
  print "\n";
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
      if($cell eq '*' && $down eq ' ') {
        $new_map->[$x][$y] = ' ';
        $new_map->[$x][$y-1] = '*';
      }

      # Rocks flow down to the right
      elsif($cell eq '*' && $down eq '*' && $right eq ' ' && $right_down eq ' ') {
        $new_map->[$x][$y] = ' ';
        $new_map->[$x+1][$y-1] = '*';
      }
      
      # Rocks flow down to the left
      elsif($cell eq '*' && $down eq '*' && $left eq ' ' && $left_down eq ' ') {
        $new_map->[$x][$y] = ' ';
        $new_map->[$x-1][$y-1] = '*';
      }
      
      # All other cases... cell remains!
      else {
        $new_map->[$x][$y] = $cell;
      }
    }
  }
  return $new_map;
}

1;

