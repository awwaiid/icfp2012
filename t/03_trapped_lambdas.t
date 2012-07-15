#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;

use lib 'lib';
use Test::More tests => 3;
use Map;
use Lifter;

my $with_trapped_map = <<END;
###########
#  \\ . ...#
#**..   . #
#.. .. .* #
#  ## #\\..#
# *\\W  ...#
#..* . ..##
###########
END


my $without_trapped_map = <<END;
###########
#  \\ . ...#
#**..   . #
#.. .. .* #
#  .  #\\..#
# *\\W  ...#
#..* . ..##
###########
END

my $multiple_trapped_map = <<END;
###########
# *\\#. ...#
#**1w   . #
#.. .. ** #
#  #  #\\2.#
# *\\W #W..#
#..* . ..##
###########
END

my ($map, $dont_care) = Lifter::load_map($with_trapped_map);

is Map::trapped_lambdas( $map ), 1, "There are trapped lambdas";

($map, $dont_care) = Lifter::load_map($without_trapped_map);

is Map::trapped_lambdas( $map ), 0, "All free";

($map, $dont_care) = Lifter::load_map($multiple_trapped_map);

is Map::trapped_lambdas( $map ), 3, "All trapped";

