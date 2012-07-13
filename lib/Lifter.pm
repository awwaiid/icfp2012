package Lifter;

use v5.10;
use strict;
use warnings;
use File::Slurp;
use Storable qw( dclone );
use JSON::XS;
use List::Util qw( max );

sub load_map {
  my $source = shift;
  my @raw_map;

  my @lines;
  my $all_lines;
  if(ref $source || ($source !~ /\n/ && -f $source)) {
    $all_lines = read_file($source, { chomp => 1 });
  } else {
    # Try to treat this as a map directly
    $all_lines = $source;
  }

  my ($map_lines, $meta_lines) = split /\n\n/, $all_lines, 2;
  $meta_lines ||= '';

  @lines = split /\n/, $map_lines;
  @lines = map { chomp; $_ } @lines;

  my $width = max( map { length $_ } @lines );
  @raw_map = map { [split //, $_] } @lines;

  my $height = scalar @raw_map;

  my $map = [];
  for(my $y = 0; $y < @raw_map; $y++) {
    my $row = $raw_map[$y];
    for(my $x = 0; $x < $width; $x++) {
      $map->[$x][$height - $y - 1] = $raw_map[$y]->[$x] || ' ';
    }
  }

  my @meta_lines = split /\n/, $meta_lines;
  @meta_lines = map { chomp; $_ } @meta_lines;
  my %meta = map { my ($k, $v) = split / /, $_; (lc $k, $v) } @meta_lines;

  return ($map, \%meta);
}

sub load_world {
  my $source = shift;
  my ($map, $meta) = load_map($source);
  my $robot_loc = get_robot_loc($map);
  my $lambda_remain = get_lambda_remain($map);
  return {
    map             => $map, # array of map data
    robot_loc       => $robot_loc, # [$x,$y] of robot
    lambda_remain   => $lambda_remain, # How many lambdas left
    lambda_count    => 0, # How many we've already gotten
    partial_score   => 0, # The pre-bonus score
    bonus_score     => 0, # The bonus for WIN or ABORT
    score           => 0, # The total (current/ending) score
    flooding_step   => 0, # How deep is the flood
    waterproof_step => 0, # How long have we been underwater
    %$meta,
  };
}

sub world_to_json {
  my $world = shift;
  return JSON::XS->new->indent(0)->encode($world);
}

sub json_to_world {
  my $json = shift;
  return JSON::XS->new->decode($json);
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
  my $world = shift;
  print map_to_string($world->{map});
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

sub get_lambda_remain {
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
  my ($world) = @_;
  my $map = $world->{map};
  my $robot_loc = $world->{robot_loc};
  my ($x, $y) = @$robot_loc;
  if($map->[$x][$y+1] eq '+') {
    return {
      %$world,
      partial_score => $world->{score},
      bonus_score   => 0,
      ending        => 'CRUSHED',
    };
  }
  if($world->{waterproof_step} >= $world->{waterproof}) {
    return {
      %$world,
      partial_score => $world->{score},
      bonus_score   => 0,
      ending        => 'DROWN',
    };
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
  return { %$world, map => $map };
}

sub world_update {
  my $world      = shift;
  my $map        = $world->{map};
  my $new_map    = [];
  my $map_height = scalar @{$map->[0]};
  my $map_width  = scalar @{$map};
  
  my $waterproof_step = $world->{waterproof_step};
  my $flooding_step   = $world->{flooding_step};
  my $water           = $world->{water};

  # Update the water level
  if($world->{flooding} > 0) {
    $flooding_step++;
    if($flooding_step > $world->{flooding}) {
      $water++;
      $flooding_step = 0;
    }
  }

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
        # say STDERR "DOWN";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x][$y-1] = '+';
      }

      # Rocks on rocks flow down to the right
      elsif($cell =~ /[*+]/ && $down =~ /[*+]/ && $right eq ' ' && $right_down eq ' ') {
        # say STDERR "rock-flow right";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x+1][$y-1] = '+';
      }

      # Rocks on rocks flow down to the left
      elsif($cell =~ /[*+]/ && $down =~ /[*+]/ && $left eq ' ' && $left_down eq ' ') {
        # say STDERR "rock-flow left";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x-1][$y-1] = '+';
      }

      # Rocks on lambdas flow down to the right
      elsif($cell =~ /[*+]/ && $down eq '\\' && $right eq ' ' && $right_down eq ' ') {
        # say STDERR "lambda-flow right";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x+1][$y-1] = '+';
      }

      # Time to open the lift!!!
      elsif($cell eq 'L' && $world->{lambda_remain} == 0) {
        $new_map->[$x][$y] = 'O';
      }

      # All other cases... cell remains!
      else {
        $new_map->[$x][$y] = $cell;

        # Update robot drowning
        if($cell eq 'R' && $world->{flooding} > 0) {
          if($y < $world->{water}) {
            $waterproof_step++;
          } else {
            $waterproof_step = 0;
          }
        }
      }
    }
  }
  return {
    %$world,
    map             => $new_map,
    water           => $water,
    waterproof_step => $waterproof_step,
    flooding_step   => $flooding_step,
  };
}

sub robot_move {
  my ($world, $move) = @_;
  my $map = dclone($world->{map});
  my $robot_loc = $world->{robot_loc};
  my $lambda_remain = $world->{lambda_remain};
  my $lambda_count = $world->{lambda_count};
  my $score = $world->{score} - 1; # Lose one point!
  $move = uc $move;
  my ($x, $y) = @$robot_loc;
  my $new_loc = [@$robot_loc];
  if($move eq 'U') {
    if($map->[$x][$y+1] eq ' '
      || $map->[$x][$y+1] eq '.'
      || $map->[$x][$y+1] eq '\\'
    ) {
      if($map->[$x][$y+1] eq '\\') {
        $lambda_remain-- ;
        $lambda_count++ ;
        $score += 25 ;
      }
      $map->[$x][$y] = ' ';
      $map->[$x][$y+1] = 'R';
      $new_loc = [$x, $y+1];
    }
    if($map->[$x][$y+1] eq 'O') {
      return {
        %$world,
        ending        => 'WIN',
        partial_score => $score,
        bonus_score   => $lambda_count * 50,
        score         => $score + $lambda_count * 50,
      };
    }
  }
  if($move eq 'D') {
    if($map->[$x][$y-1] eq ' '
      || $map->[$x][$y-1] eq '.'
      || $map->[$x][$y-1] eq '\\'
    ) {
      if($map->[$x][$y-1] eq '\\') {
        $lambda_remain-- ;
        $lambda_count++ ;
        $score += 25 ;
      }
      $map->[$x][$y] = ' ';
      $map->[$x][$y-1] = 'R';
      $new_loc = [$x, $y-1];
    }
    if($map->[$x][$y-1] eq 'O') {
      return {
        %$world,
        ending        => 'WIN',
        partial_score => $score,
        bonus_score   => $lambda_count * 50,
        score         => $score + $lambda_count * 50,
      };
    }
  }
  if($move eq 'R') {
    if($map->[$x+1][$y] eq ' '
      || $map->[$x+1][$y] eq '.'
      || $map->[$x+1][$y] eq '\\'
    ) {
      if($map->[$x+1][$y] eq '\\') {
        $lambda_remain-- ;
        $lambda_count++ ;
        $score += 25 ;
      }
      $map->[$x][$y] = ' ';
      $map->[$x+1][$y] = 'R';
      $new_loc = [$x+1, $y];
    }
    if($map->[$x+1][$y] eq 'O') {
      return {
        %$world,
        ending        => 'WIN',
        partial_score => $score,
        bonus_score   => $lambda_count * 50,
        score         => $score + $lambda_count * 50,
      };
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
      if($map->[$x-1][$y] eq '\\') {
        $lambda_remain-- ;
        $lambda_count++ ;
        $score += 25 ;
      }
      $map->[$x][$y] = ' ';
      $map->[$x-1][$y] = 'R';
      $new_loc = [$x-1, $y];
    }
    if($map->[$x-1][$y] eq 'O') {
      return {
        %$world,
        ending        => 'WIN',
        partial_score => $score,
        bonus_score   => $lambda_count * 50,
        score         => $score + $lambda_count * 50,
      };
    }
    if($map->[$x-1][$y] =~ /[*+]/ && $map->[$x-2][$y] eq ' ') {
      $map->[$x][$y] = ' ';
      $map->[$x-1][$y] = 'R';
      $map->[$x-2][$y] = '*';
      $new_loc = [$x-1, $y];
    }
  }
  if($move eq 'A') {
    print "You ABORT!\n";
    print "Partial score: $score\n";
    print "Bonus: " . ($lambda_count * 25) . "\n";
    print "Total: " . ($score + $lambda_count * 25) . "\n";
    exit;
  }

  return {
    %$world,
    map           => $map,
    robot_loc     => $new_loc,
    lambda_remain => $lambda_remain,
    lambda_count  => $lambda_count,
    partial_score => $score,
    score         => $score,
  };
}

1;

