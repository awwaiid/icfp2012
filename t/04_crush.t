#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Lifter;

my $crush_map_path = 't/test_maps/crush.map';
ok -e $crush_map_path, "Crush map found";

my $world = Lifter::load_world( $crush_map_path );

$world = Lifter::eval_move($world, 'W');
is $world->{ending}, 'CRUSHED', 'Got crushed!';

my $crush_hor_map_path = 't/test_maps/crush_hor.map';
ok -e $crush_hor_map_path, "Crush map found";

$world = Lifter::load_world( $crush_hor_map_path );

$world = Lifter::eval_move($world, 'W');
is $world->{ending}, 'CRUSHED', 'Got crushed by HORock!';

done_testing();

