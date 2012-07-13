#!/usr/bin/env perl

use strict;

use v5.10;
use Test::More tests => 5;
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
