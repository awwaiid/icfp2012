<?php

class MathFacade {

    public static function findDistanceBetweenTwoPositions(Position $a, Position $b) {
        $d = sqrt( pow($b->x - $a->x,2) + pow($b->y - $a->y,2) );
        return $d;
    }

    public static function findMDistanceBetweenTwoPositions(Position $a, Position $b) {
        $d = abs($b->x - $a->x) + abs($b->y - $a->y);
        return $d;
    }

}