package Lifter;

use v5.10;
use strict;
use warnings;
use File::Slurp;
use Storable qw( dclone );
use JSON::XS;
use List::Util qw( max );
# use Memoize;
# memoize( 'eval_move' );

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
  my @trampoline_lines = grep { /^Trampoline/ } @meta_lines;
  @meta_lines = grep { ! /^Trampoline/ } @meta_lines;
  my %meta = map { my ($k, $v) = split / /, $_; (lc $k, $v) } @meta_lines;

  my $trampoline_forward = {};
  my $trampoline_back    = {};

  foreach my $trampoline_line (@trampoline_lines) {
    if($trampoline_line =~ /^Trampoline ([A-I]) targets ([1-9])$/) {
      my ($from, $to) = ($1, $2);
      $trampoline_forward->{$from} = $to;
      push @{ $trampoline_back->{$to} }, $from;
    }
  }
  $meta{trampoline_forward} = $trampoline_forward;
  $meta{trampoline_back}    = $trampoline_back;

  return ($map, \%meta);
}

sub load_world {
  my $source         = shift;
  my ($map, $meta)   = load_map($source);
  my $robot_loc      = get_robot_loc($map);
  my $lambda_remain  = get_lambda_remain($map);
  my $trampoline_loc = get_trampoline_loc($map);
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
    water           => 0, # default water level
    flooding        => 0, # default flooding rate
    waterproof      => 10,# default waterproofing
    move_count      => 0, # simple count of moves
    trampoline_loc  => $trampoline_loc, # Location of each trampoline
    growth          => 25,# beard growth rate
    growth_step     => 0, # current growth step
    razors          => 0, # default current razor count
    %$meta,
  };
}

sub world_to_json {
  my $world = shift;
  my $flip_map = shift || 0;
  $world = flip_map($world, 1) if $flip_map;
  return JSON::XS->new->indent(0)->encode($world);
}

sub json_to_world {
  my $json = shift;
  my $flip_map = shift || 0;
  my $world = JSON::XS->new->decode($json);
  $world = flip_map($world, 0) if $flip_map;
  return $world;
}

sub flip_map {
  my $world = shift;
  my $direction = shift;
  my $map = $world->{map};
  my $new_map = [];
  my ($width, $height);
  if($direction) {
    $width = scalar @$map;
    $height = scalar @{ $map->[0] };
  } else {
    $height = scalar @$map;
    $width = scalar @{ $map->[0] };
  }
  for(my $x = 0; $x < $width; $x++) {
    for(my $y = 0; $y < $height; $y++) {
      if($direction) {
        $new_map->[$height - $y - 1][$x] = $map->[$x][$y] // ' ';
      } else {
        $new_map->[$x][$height - $y - 1] = $map->[$y][$x] // ' ';
      }
    }
  }
  return { %$world, map => $new_map };
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

sub get_lift_loc {
  my $map = shift;

  my $width = scalar @$map;
  my $height = scalar @{ $map->[0] };

  for(my $y = 0; $y < $height; $y++) {
    for(my $x = 0; $x < $width; $x++) {
      return [$x, $y] if $map->[$x][$y] eq 'O' || $map->[$x][$y] eq 'L';
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
      $count++ if $map->[$x][$y] =~ /[\\@]/;
    }
  }
  return $count;
}

sub get_trampoline_loc {
  my $map = shift;

  my $trampoline_loc = {};

  my $width = scalar @$map;
  my $height = scalar @{ $map->[0] };

  for(my $y = 0; $y < $height; $y++) {
    for(my $x = 0; $x < $width; $x++) {
      $trampoline_loc->{$map->[$x][$y]} = [$x, $y]
        if $map->[$x][$y] =~ /[A-I1-9]/;
    }
  }
  return $trampoline_loc;
}

sub check_ending {
  my ($world) = @_;
  return $world if $world->{ending};
  my $map = $world->{map};
  my $robot_loc = $world->{robot_loc};
  my ($x, $y) = @$robot_loc;
  if($map->[$x][$y+1] =~ /\+\|/) {
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
  # Flip the rocks back to stars, and smash HOR
  my $new_map = dclone($map);
  my $map_height = scalar @{$new_map->[0]};
  my $map_width  = scalar @{$new_map};
  for(my $y = 1; $y < $map_height; $y++) {
    for(my $x = 0; $x < $map_width; $x++) {
      if($new_map->[$x][$y] eq '|' && $new_map->[$x][$y - 1] ne ' ') {
        $new_map->[$x][$y] = '\\';
      }
      $new_map->[$x][$y] =~ tr/+|/*@/;
    }
  }
  return { %$world, map => $new_map };
}

sub world_update {
  my $world      = shift;
  return $world if $world->{ending};
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

  # Update beard growth level
  my $growth_step = $world->{growth_step};
  my $do_grow_beard = 0;
  if($world->{growth} > 0) {
    $growth_step++;
    if($growth_step >= $world->{growth}) {
      $do_grow_beard = 1;
      $growth_step = 0;
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
      if($cell =~ /[*@]/ && $down eq ' ') {
        # say STDERR "DOWN";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x][$y-1] = $cell eq '*' ? '+' : '|';
      }

      # Rocks on rocks flow down to the right
      elsif($cell =~ /[*@]/ && $down =~ /[*@]/ && $right eq ' ' && $right_down eq ' ') {
        # say STDERR "rock-flow right";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x+1][$y-1] = $cell eq '*' ? '+' : '|';
      }

      # Rocks on rocks flow down to the left
      elsif($cell =~ /[*@]/ && $down =~ /[*@]/ && $left eq ' ' && $left_down eq ' ') {
        # say STDERR "rock-flow left";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x-1][$y-1] = $cell eq '*' ? '+' : '|';
      }

      # Rocks on lambdas flow down to the right
      elsif($cell =~ /[*@]/ && $down eq '\\' && $right eq ' ' && $right_down eq ' ') {
        # say STDERR "lambda-flow right";
        $new_map->[$x][$y] = ' ';
        $new_map->[$x+1][$y-1] = $cell eq '*' ? '+' : '|';
      }

      # Time to open the lift!!!
      elsif($cell eq 'L' && $world->{lambda_remain} == 0) {
        $new_map->[$x][$y] = 'O';
      }

      elsif($cell eq ' ' && defined $new_map->[$x][$y] && $new_map->[$x][$y] eq 'W') {
        # New beard wins!
      }

      # All other cases... cell remains!
      else {
        $new_map->[$x][$y] = $cell;

        if($cell eq 'W' && $do_grow_beard) {
          # Time to grow that beard!
          # say "Growing beard $x,$y";
          for my $i (-1..1) {
            for my $j (-1..1) {
              my $xi = $x + $i;
              my $yj = $y + $j;
              # say "... checking $xi,$yj";
              if($xi >= 0 && $xi < $map_width && $yj >= 0 && $yj < $map_height
                && $map->[$xi][$yj] eq ' ') {
                  # say "... GROWING $xi,$yj";
                  $new_map->[$xi][$yj] = 'W';
              }
            }
          }
        }

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
    growth_step     => $growth_step,
  };
}

sub robot_move {
  my ($world, $move) = @_;
  return $world if $world->{ending};
  my $map = dclone($world->{map});
  my $robot_loc = $world->{robot_loc};
  my $lambda_remain = $world->{lambda_remain};
  my $lambda_count = $world->{lambda_count};
  my $razors = $world->{razors};
  my $score = $world->{score} - 1; # Lose one point!
  my $move_count = $world->{move_count} + 1;
  $move = uc $move;
  my ($x, $y) = @$robot_loc;
  my $new_loc = [@$robot_loc];

  # Yes... nested sub to make scoping easy
  my $robot_move_to = sub {
    my ($i, $j) = @_;

    if($map->[$i][$j] eq '\\') {
      $lambda_remain-- ;
      $lambda_count++ ;
      $score += 25 ;
    }
    if($map->[$i][$j] eq '!') {
      $razors++;
    }
    if($map->[$i][$j] =~ /[A-I]/) {
      my $trampoline = $map->[$i][$j];
      my $trampoline_target = $world->{trampoline_forward}->{$trampoline};

      # Set up our new destination
      # use Data::Printer;
      # p $trampoline_target;
      # p $world->{trampoline_loc};
      # p $world->{trampoline_loc}->{$trampoline_target};
      ($i, $j) = @{ $world->{trampoline_loc}->{$trampoline_target} };

      # Clear all origin trampolines, including original
      foreach my $tramp (@{ $world->{trampoline_back}->{$trampoline_target} }) {
        my ($tramp_x, $tramp_y) = @{ $world->{trampoline_loc}->{$tramp} };
        $map->[$tramp_x][$tramp_y] = ' ';
      }
    }
    $map->[$x][$y] = ' ';
    $map->[$i][$j] = 'R';
    $new_loc = [$i, $j];
  };

  my $robot_win = sub {
    return {
      %$world,
      move_count    => $move_count,
      ending        => 'WIN',
      partial_score => $score,
      bonus_score   => $lambda_count * 50,
      score         => $score + $lambda_count * 50,
    };
  };

  if($move eq 'U') {
    if($map->[$x][$y+1] =~ /[ .\\A-I!]/) {
      $robot_move_to->($x, $y+1);
    }
    if($map->[$x][$y+1] eq 'O') {
      return $robot_win->();
    }
  }
  if($move eq 'D') {
    if($map->[$x][$y-1] =~ /[ .\\A-I!]/) {
      $robot_move_to->($x, $y-1);
    }
    if($map->[$x][$y-1] eq 'O') {
      return $robot_win->();
    }
  }
  if($move eq 'R') {
    if($map->[$x+1][$y] =~ /[ .\\A-I!]/) {
      $robot_move_to->($x+1, $y);
    }
    if($map->[$x+1][$y] eq 'O') {
      return $robot_win->();
    }

    # Push boulder
    if($map->[$x+1][$y] =~ /[*@]/ && $map->[$x+2][$y] eq ' ') {
      $map->[$x][$y] = ' ';
      $map->[$x+2][$y] = $map->[$x+1][$y];
      $map->[$x+1][$y] = 'R';
      $new_loc = [$x+1, $y];
    }
  }
  if($move eq 'L') {
    if($map->[$x-1][$y] =~ /[ .\\A-I!]/) {
      $robot_move_to->($x-1, $y);
    }
    if($map->[$x-1][$y] eq 'O') {
      return $robot_win->();
    }
    # Push boulder
    if($map->[$x-1][$y] =~ /[*@]/ && $map->[$x-2][$y] eq ' ') {
      $map->[$x][$y] = ' ';
      $map->[$x-2][$y] = $map->[$x-1][$y];
      $map->[$x-1][$y] = 'R';
      $new_loc = [$x-1, $y];
    }
  }
  if($move eq 'A') {
    $score++; # give it back!
    return {
      %$world,
      move_count    => $move_count,
      ending        => 'ABORT',
      partial_score => $score,
      bonus_score   => $lambda_count * 25,
      score         => $score + $lambda_count * 25,
    };
  }
  if($move eq 'S') {
    if($razors > 0) {
      $razors--;
      for my $i (-1..1) {
        for my $j (-1..1) {
          my $xi = $x + $i;
          my $yj = $y + $j;
          # say "... checking $xi,$yj";
          if($xi >= 0
              && $yj >= 0
              && defined $map->[$xi][$yj]
              && $map->[$xi][$yj] eq 'W') {
            # say "... GROWING $xi,$yj";
            $map->[$xi][$yj] = ' ';
          }
        }
      }
    }
  }

  return {
    %$world,
    move_count    => $move_count,
    map           => $map,
    robot_loc_prev=> $robot_loc,
    robot_loc     => $new_loc,
    lambda_remain => $lambda_remain,
    lambda_count  => $lambda_count,
    partial_score => $score,
    score         => $score,
    razors        => $razors,
  };
}

{
    my %cache;

    sub eval_move {
        my $world = shift;
        my $move = shift;

        my $key = world_to_json( $world) . $move;
        if ( $cache{ $key } ) {
            return $cache{ $key };
        }
        else {
            $world = Lifter::robot_move($world, $move);
            $world = Lifter::check_ending($world);
            $world = Lifter::world_update($world);
            $world = Lifter::check_ending($world);

            $cache{ $key } = $world;
            return $world;
        }
    }
}
1;

