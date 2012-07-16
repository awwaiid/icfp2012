#!/usr/bin/env perl

use lib '../lib';
use v5.10;
use strict;
use warnings;
use Data::Dumper;
use Lifter;
my $map = join "", "../map/", shift @ARGV;
my $world = Lifter::load_world($map);
print Lifter::world_to_json($world, 1);