#!/usr/bin/env perl

use strict;

use v5.10;
use Test::More tests => 15;
use lib 'lib';
use Lifter;
use Data::Printer;

## Test map that doesn't change

{
    my $no_change_map_path = 't/test_maps/no_change.map';
    ok -e $no_change_map_path, "Non changing map found";

    my $no_change_map = `cat t/test_maps/no_change.map`;

    my $new_map = Lifter::map_to_string( Lifter::map_update( Lifter::load_map( $no_change_map_path ) ) ); 

    is $new_map, $no_change_map, "Map stayed the same";
}

## Test map that should only change once

{
    my $map_path = 't/test_maps/single_change.map';
    ok -e $map_path, "Single change map found";

    my $expected_map = `cat t/test_maps/single_change_final.map`;

    my $new_map = Lifter::map_update( Lifter::load_map( $map_path ) ); 

    is Lifter::map_to_string($new_map), $expected_map, "Map updated as expected";

    $new_map = Lifter::map_update( $new_map );

    is Lifter::map_to_string($new_map), $expected_map, "Map not updated second run";
}

## Test rock fall to side

{
    my $map_path = 't/test_maps/side_fall.map';
    ok -e $map_path, "Rock fall to side map found";

    my $expected_map = `cat t/test_maps/side_fall_final.map`;

    my $new_map = Lifter::map_update( Lifter::load_map( $map_path ) ); 

    is Lifter::map_to_string($new_map), $expected_map, "Map updated as expected";

}

## Test rock fall to side of lambda

{
    my $map_path = 't/test_maps/lambda_fall.map';
    ok -e $map_path, "Rock fall to side of lambda map found";

    my $expected_map = `cat t/test_maps/lambda_fall_final.map`;

    my $new_map = Lifter::map_update( Lifter::load_map( $map_path ) ); 

    is Lifter::map_to_string($new_map), $expected_map, "Map updated as expected";

}

## Test rock not falling to side of lambda

{
    my $map_path = 't/test_maps/lambda_not_fall.map';
    ok -e $map_path, "Rock not falling to lambda side map found";

    my $expected_map = `cat t/test_maps/lambda_not_fall_final.map`;

    my $new_map = Lifter::map_update( Lifter::load_map( $map_path ) ); 

    is Lifter::map_to_string($new_map), $expected_map, "Map updated as expected";

}

## Test successive rock fall

{
    my $map_path = 't/test_maps/successive_rock.map';
    ok -e $map_path, "Successive rock fall map found";

    my $expected_map = `cat t/test_maps/successive_rock_final.map`;

    my $new_map = Lifter::map_update( Lifter::load_map( $map_path ) ); 

    is Lifter::map_to_string($new_map), $expected_map, "Map updated as expected";
}

## Test off by one error

{
    my $map_path = 't/test_maps/off_by_one.map';
    ok -e $map_path, "Off by one error map found";

    my $expected_map = `cat t/test_maps/off_by_one_final.map`;

    my $loaded_map = Lifter::load_map( $map_path );
    my $new_map = Lifter::map_update( Lifter::robot_move( $loaded_map, Lifter::get_robot_loc( $loaded_map ), 'L' )  ); 

    is Lifter::map_to_string($new_map), $expected_map, "Map updated as expected";
}
