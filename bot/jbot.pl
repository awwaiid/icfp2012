#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';
use List::Util qw( max );
use JSON::XS;
use Lifter;

use IO::Scalar;
STDIN->autoflush(1);
STDOUT->autoflush(1);

# my @moves = qw( L R U D W );
my @moves = qw( L R U D );

while(1) {
  my $input = <>;
  exit unless $input;
  chomp $input;
  my $cmd = join("","/usr/bin/php ", `pwd` , "/lambda-miner/phpbot.php '", $input, "'");
  print $cmd;
  my $move = `$cmd`;
  print "$move\n";
}

