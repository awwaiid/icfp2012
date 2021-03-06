#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use IO::Handle;
use JSON::XS;
use Data::Printer;

STDIN->autoflush(1);
STDOUT->autoflush(1);

# This bot checks the 4 adjacent squares for lambdas
# if it finds one it moves the bot to that square and
# check the 4 adjacent squares and repeats
# otherwise it aborts.


my @moves = qw( L R U D W );

while(1) {
  my $input = <>;
  exit unless $input;
  chomp $input;

  my $world = decode_json($input);

  my $move = check_lambda( $world ) || 'A';
  print "$move\n";
}


sub check_lambda {
    my $world = shift;

    my $map = $world->{map};
    my $robot_x = $world->{robot_loc}[0];
    my $robot_y = $world->{robot_loc}[1];

    # have to check if the index is 0 on negatives so we don't wrap around
    if ( $map->[$robot_x][$robot_y + 1] eq '\\' ) {
        return 'U';
    }
    elsif ($robot_y &&  $map->[$robot_x][$robot_y - 1] eq '\\' ) {
        return 'D';
    }
    elsif ( $map->[$robot_x + 1][$robot_y] eq '\\' ) {
        return 'R';
    }
    elsif ( $robot_x && $map->[$robot_x - 1][$robot_y] eq '\\' ) {
        return 'L';
    }
    else {
        return;
    }
}
