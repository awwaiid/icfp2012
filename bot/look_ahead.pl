#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';
use List::Util qw( max shuffle );
use JSON::XS;
use Algorithm::Combinatorics qw( tuples_with_repetition );
use Lifter;

use Data::Printer;

use IO::Scalar;
STDIN->autoflush(1);
STDOUT->autoflush(1);

# my @types = qw( L R U D W A );
my @types = qw( L R U D );
my $look_ahead = 5;
my @moves = tuples_with_repetition( \@types, $look_ahead);

local $SIG{INT} = sub {
    # say STDERR "Interrupt!\n";
    # # say STDERR "Best score = " . $world->{score }. "\n";
    # print "A\n";
    # my $input = <>;
    # chomp $input;

    # my $world = decode_json($input);
    # say "Result: $world->{ending}!";
    # say "Partial score: $world->{partial_score}";
    # say "Bonus score: $world->{bonus_score}";
    # say "Final score: $world->{score}";
    print "A\n";
    exit;
};

my $input = <>;

while(1) {
    exit unless $input;
    chomp $input;

    @moves = shuffle @moves;
    my $world = decode_json($input);

    my $choices = {};
    for my $set ( @moves ) {
        my $new_world = $world;
        my $this_set = join('_', @$set);
        for my $move (@$set) {
            $new_world = Lifter::robot_move($new_world, $move);
            $new_world = Lifter::check_ending($new_world);
            $new_world = Lifter::world_update($new_world);
            $new_world = Lifter::check_ending($new_world);
        }
        $choices->{$this_set} = $new_world->{score};
    }
# p($choices);

    my %by_score = reverse %$choices;
    my $best_score = max values %$choices;

    # if the high score is 0 we still want to move
    # so lets keep track of the first set of moves
    # that goes $look_ahead or fewer steps away
    # if ( $best_score == 0 ) {
# say STDERR "best score was 0, looking for just movement";
        # my $possible_move = - $look_ahead;
        # while ( $possible_move ) {
            # if ($by_score{ $possible_move }) {
                # $best_score = $possible_move;
                # last;
            # }
            # else {
                # $possible_move++;  # work our way to 0
            # }
        # }
    # }

say STDERR "best score is $best_score : movement is " . $by_score{$best_score};
    my @sequence = split('_', $by_score{$best_score} );

    for my $move ( @sequence ) {
        print "$move\n";
        $input = <>;
    }
}

