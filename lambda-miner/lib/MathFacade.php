<?php

class MathFacade {

    public static function findSDistanceBetweenTwoPositions(Position $a, Position $b) {
        //$GLOBALS['log']->lwrite(" SD:" . $a . '-' . $b);
        if (abs($b->x - $a->x) == 0) {
            $d = abs($b->y - $a->y);
        }
        else if (abs($b->y - $a->y) == 0) {
            $d = abs($b->x - $a->x);
        }
        else {
            $d = 0;
        }
        return $d;
    }

    public static function findMDistanceBetweenTwoPositions(Position $a, Position $b) {
        $d = abs($b->x - $a->x) + abs($b->y - $a->y);
        return $d;
    }

}