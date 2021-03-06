#!/usr/bin/env perl

use strict;

use v5.10;
use Test::More tests => 16;
use lib 'lib';
use Lifter;
use Data::Printer;

## Test map that doesn't change

{
    my $no_change_map_path = 't/test_maps/no_change.map';
    ok -e $no_change_map_path, "Non changing map found";

    my $no_change_map = `cat t/test_maps/no_change.map`;

    my $new_world = Lifter::world_update( Lifter::load_world( $no_change_map_path ) );

    is Lifter::map_to_string($new_world->{map}), $no_change_map, "Map stayed the same";
}

## Test map that should only change once

{
    my $map_path = 't/test_maps/single_change.map';
    ok -e $map_path, "Single change map found";

    my $expected_map = `cat t/test_maps/single_change_final.map`;

    my $new_world = Lifter::world_update( Lifter::load_world( $map_path ) ); 

    is Lifter::map_to_string($new_world->{map}), $expected_map, "Map updated as expected";

    $new_world = Lifter::world_update( $new_world );

    is Lifter::map_to_string($new_world->{map}), $expected_map, "Map not updated second run";
}

## Test rock fall to side

{
    my $map_path = 't/test_maps/side_fall.map';
    ok -e $map_path, "Rock fall to side map found";

    my $expected_map = `cat t/test_maps/side_fall_final.map`;

    my $new_world = Lifter::world_update( Lifter::load_world( $map_path ) ); 

    is Lifter::map_to_string($new_world->{map}), $expected_map, "Map updated as expected";

}

## Test rock fall to side of lambda

{
    my $map_path = 't/test_maps/lambda_fall.map';
    ok -e $map_path, "Rock fall to side of lambda map found";

    my $expected_map = `cat t/test_maps/lambda_fall_final.map`;

    my $new_world = Lifter::world_update( Lifter::load_world( $map_path ) ); 

    is Lifter::map_to_string($new_world->{map}), $expected_map, "Map updated as expected";

}

## Test rock not falling to side of lambda

{
    my $map_path = 't/test_maps/lambda_not_fall.map';
    ok -e $map_path, "Rock not falling to lambda side map found";

    my $expected_map = `cat t/test_maps/lambda_not_fall_final.map`;

    my $new_world = Lifter::world_update( Lifter::load_world( $map_path ) ); 

    is Lifter::map_to_string($new_world->{map}), $expected_map, "Map updated as expected";

}

## Test successive rock fall

{
    my $map_path = 't/test_maps/successive_rock.map';
    ok -e $map_path, "Successive rock fall map found";

    my $expected_map = `cat t/test_maps/successive_rock_second.map`;

    my $new_world = Lifter::world_update( Lifter::load_world( $map_path ) ); 

    is Lifter::map_to_string($new_world->{map}), $expected_map, "Map updated as expected";

    $expected_map = `cat t/test_maps/successive_rock_final.map`;
    $new_world = Lifter::world_update( $new_world );
    is Lifter::map_to_string($new_world->{map}), $expected_map, "Final map updated as expected";
}

## Test off by one error

{
    my $map_path = 't/test_maps/off_by_one.map';
    ok -e $map_path, "Off by one error map found";

    my $expected_map = `cat t/test_maps/off_by_one_final.map`;

    my $loaded_world = Lifter::load_world( $map_path );
    my $new_world = Lifter::world_update( Lifter::robot_move( $loaded_world, 'L' )  ); 

    is Lifter::map_to_string($new_world->{map}), $expected_map, "Map updated as expected";
}
