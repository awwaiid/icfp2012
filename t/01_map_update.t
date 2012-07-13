#!/usr/bin/env perl

use strict;

use v5.10;
use Test::More tests => 2;
use lib 'lib';
use Lifter;
use Data::Printer;

my $no_change_map_path = 't/test_maps/no_change.map';
ok -e $no_change_map_path, "Non changing map found";

my $no_change_map = `cat t/test_maps/no_change.map`;

my $new_map = Lifter::map_to_string( Lifter::map_update( Lifter::load_map( $no_change_map_path ) ) ); 

is $new_map, $no_change_map, "Map stayed the same";
