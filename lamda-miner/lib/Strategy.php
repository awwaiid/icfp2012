<?php

class Strategy {

    function __construct() {

    }

    public function findPathToTarget(Position $origin, Position $target) {

    }

    public function findClosestLamda(Position $origin, Map $map) {

        $lamdas = WorldFacade::findLambdas($map)

    }

}