package Map;

use v5.10;
use strict;
use warnings;

# returns count of things found trapped
sub trapped_thing {
    my $test = shift;
    my $map = shift;

    my $count = 0;
    my $width = scalar @$map;
    my $height = scalar @{ $map->[0] };
    my $blocked = qr/[#@*W1-9]/;
    for(my $y = $height - 1; $y >= 0; $y--) {
        for(my $x = 0; $x < $width; $x++) {
            if ($map->[$x][$y] =~ $test) {
                if ( ! $x || $map->[$x - 1][$y] =~ $blocked ) {
                    if ( $x == ($width - 1) || $map->[$x + 1][$y] =~ $blocked ) {
                        if ( ! $y || $map->[$x][$y - 1] =~ $blocked ) {
                            if ( $y == ( $height - 1 ) || $map->[$x][$y + 1] =~ $blocked  ) {
                                $count++;
                            }
                        }
                    }
                }
            }
        }
    }

    return $count;
}

# returns count if lambdas that are trapped
sub trapped_lambdas {
    my $map = shift;

    return trapped_thing(qr/\\/, $map);
}

# returns true if the lift is trapped
sub trapped_lift {
    my $map = shift;

    return trapped_thing(qr/L|O/, $map);
}

# returns true if the robot is trapped
sub trapped_robot {
    my $map = shift;

    return trapped_thing(qr/R/, $map);
}


1;
