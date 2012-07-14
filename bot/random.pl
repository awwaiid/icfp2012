#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use IO::Handle;
use JSON::XS;

STDIN->autoflush(1);
STDOUT->autoflush(1);

my @moves = qw( L R U D W );

while(1) {
  my $input = <>;
  exit unless $input;
  chomp $input;

  # we don't use world... but if we did...
  my $world = decode_json($input);

  my $move = $moves[int rand scalar @moves];
  print "$move\n";
}

