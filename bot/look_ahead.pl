#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use lib 'lib';
use List::Util qw( max shuffle );
use JSON::XS;
use Algorithm::Combinatorics qw( tuples_with_repetition );
use Lifter;
use Map;

use Data::Printer;

use IO::Scalar;
STDIN->autoflush(1);
STDOUT->autoflush(1);

# my @types = qw( L R U D W A );
my @types = qw( L R U D );
my $look_ahead = 7;
my @moves = tuples_with_repetition( \@types, $look_ahead);

local $SIG{INT} = sub {
    print "A\n";
    exit;
};

my $input = <>;

while(1) {
    exit unless $input;
    chomp $input;

    my $world = decode_json($input);
    my $should_abort = 0;

    # Can't get any more lambdas so might as well just leave
    my $lambdas_left = Lifter::get_lambda_remain( $world->{map});
    if ( $lambdas_left && $lambdas_left == Map::trapped_lambdas( $world->{map} ) ) {
        say STDERR "nothin but trapped lambdas";
        $should_abort = 1;
    }

    if ( Map::trapped_lift( $world->{map} ) && ! $lambdas_left ) {
        say STDERR "trapped lift and no lambdas left";
        $should_abort = 1;
    }

    if ( Map::trapped_robot( $world->{map} ) ) {
        say STDERR "trapped robot";
        $should_abort = 1;
    }

    if ( $should_abort ) {
        print "A\n";
        exit;
    }

    my $choices = {};
    for my $set ( @moves ) {
        my $new_world = $world;
        my $this_set = join('_', @$set);
        for my $move (@$set) {
            $new_world = Lifter::eval_move( $new_world, $move);
        }
        my $set_score;
        if ( $new_world->{ending} && $new_world->{ending} =~ /CRUSHED|DROWN/ ) {
            $set_score = -1000000;
        }
        else {
            $set_score = $new_world->{score};
        }

        $choices->{$this_set} = $set_score;
    }
# p($choices);

    # $scores{ <score value> } = [<array of moves that come to that score>]
    my %scores;
    for my $k ( keys %$choices ) {
        push @{ $scores{ $choices->{ $k }} }, $k
    }

    # my %by_score = reverse %$choices;
    my $best_score = max keys %scores;

    my @next_moves = shuffle( @{ $scores{ $best_score } } );
say STDERR "best score is $best_score : movement is " . $next_moves[0];
    my @sequence = split('_', $next_moves[0] );

    for my $move ( @sequence ) {
        print "$move\n";
        $input = <>;
    }
}

