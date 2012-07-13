#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use IO::Scalar;

STDIN->autoflush(1);
STDOUT->autoflush(1);

my @moves = qw( L R U D W );

while(1) {
  my $world = <>;
  my $move = $moves[int rand scalar @moves];
  print "$move\n";
}

