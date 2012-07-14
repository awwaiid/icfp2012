<?php

class Strategy {

    function __construct() {

    }

    public function findPathToTarget(Position $origin, Position $target) {

    }

    public function findClosestLamda(Position $origin, Map $map) {

        $lamdas = WorldFacade::findLambdas($map);

        $least_dist = null;
        $target_lamda = null;
        foreach ($lamdas as $l) {
            $d = MathFacade::findDistanceBetweenTwoPositions($origin, $l);
            if (!$least_dist || $d < $least_dist) {
                $least_dist = $d;
                $target_lamda = $l;
            }
        }

        return $target_lamda;
    }

    public function findDirectionToTarget(Position $origin, Position $target) {

    }


}