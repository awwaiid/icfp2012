#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';
use Test::More;
use Lifter;


my $funny_map_path = 't/test_maps/funny_shape.map';
ok -e $funny_map_path, "Non changing map found";

my $world = Lifter::load_world( $funny_map_path );

my $world_json            = Lifter::world_to_json($world);
my $world_json_world      = Lifter::json_to_world($world_json);
my $world_json_world_json = Lifter::world_to_json($world_json_world);

is_deeply $world, $world_json_world, 'World -> JSON -> World';
is_deeply $world_json, $world_json_world_json, 'JSON -> World -> JSON';

my $flipped_world_json            = Lifter::world_to_json($world,1);
my $flipped_world_json_world      = Lifter::json_to_world($flipped_world_json,1);
my $flipped_world_json_world_json = Lifter::world_to_json($flipped_world_json_world,1);

is_deeply $world, $flipped_world_json_world, 'FLIPPED: World -> JSON -> World';
is_deeply $flipped_world_json, $flipped_world_json_world_json, 'FLIPPED: JSON -> World -> JSON';

done_testing();

