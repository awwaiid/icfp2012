<?php

class MathFacade {

    public static function findDistanceBetweenTwoPoints($a, $b) {

        // $d = sqrt ((b0 - a0)^2 + (b1 - a1)^2)

        $d = sqrt( pow($b['w'] - $a['w'],2) + pow($b['h'] - $a['h'],2) );
        return $d;

    }

}