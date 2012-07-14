#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';
use List::Util qw( max );
use JSON::XS;
use Algorithm::Combinatorics qw( tuples_with_repetition );
use Lifter;

use Data::Printer;

use IO::Scalar;
STDIN->autoflush(1);
STDOUT->autoflush(1);

my @types = qw( L R U D W A );
my @moves = tuples_with_repetition( \@types, 3);

my $input = <>;

while(1) {
    exit unless $input;
    chomp $input;

    my $world = decode_json($input);

    my $choices = {};
    for my $set ( @moves ) {
        my $new_world;
        my $this_set = join('_', @$set);
        for my $move (@$set) {
            $new_world = Lifter::robot_move($world, $move);
say STDERR "robot move on $move:\n", Lifter::map_to_string($new_world->{map}) if $this_set eq 'D_L_L';
            $new_world = Lifter::check_ending($new_world);
say STDERR "check end on $move:\n", Lifter::map_to_string($new_world->{map}) if $this_set eq 'D_L_L';
            $new_world = Lifter::world_update($new_world);
say STDERR "world update on $move:\n", Lifter::map_to_string($new_world->{map}) if $this_set eq 'D_L_L';
            $new_world = Lifter::check_ending($new_world);
say STDERR "check end again on $move:\n", Lifter::map_to_string($new_world->{map}) if $this_set eq 'D_L_L';
            $choices->{$this_set} += $new_world->{score};
        }
    }
# p($choices);

    my %by_score = reverse %$choices;
    my $best_score = max values %$choices;
    my @sequence = split('_', $by_score{$best_score} );

    for my $move ( @sequence ) {
        print STDERR "My move: $move\n";
        print "$move\n";
        $input = <>;
    }
}

