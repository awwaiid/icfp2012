<?php

class Strategy {

    public $world;
    public $attempt_count = 0;

    function __construct($world) {
        $this->world = $world;
    }

    public function findPathToTarget(Position $origin, Position $target) {

    }

    public function findClosestLamda(Position $origin) {

        $lamdas = WorldFacade::findLambdas($this->world->getMap());

        $least_dist = null;
        $target_lamda = null;
        foreach ($lamdas as $l) {
            $d = MathFacade::findMDistanceBetweenTwoPositions($origin, $l);
            //$GLOBALS['log']->lwrite($d);
            if (!$least_dist || $d < $least_dist) {
                $least_dist = $d;
                $target_lamda = $l;
            }
            if ($d == $least_dist && !is_null($target_lamda)) {
                $d2 = MathFacade::findMDistanceBetweenTwoPositions($l, WorldFacade::findLift($this->world->getMap()));
                $d3 = MathFacade::findMDistanceBetweenTwoPositions($target_lamda, WorldFacade::findLift($this->world->getMap()));
                if ($d2 > $d3) {
                    $target_lamda = $l;
                    $least_dist = $d;
                }
            }
        }
        return $target_lamda;
    }

    public function findDirectionToTarget(Position $origin, Position $target) {

        // get adjacent positions
        $positions = WorldFacade::getAdjacentPositions($this->world->getMap(), $origin);

        //filter out last Position and rocks
        $GLOBALS['log']->lwrite('Adjacent Positions:');
        $prev_loc_hold = null;
        foreach ($positions as $k=>$p) {

            if ($this->world->getRobotLocPrev() && $p['pos']->__toString() == $this->world->getRobotLocPrev()->__toString()) {
                $prev_loc_hold = $positions[$k];
                unset ($positions[$k]);
                continue;
            }
            if ($p['type'] == '*') {
                unset ($positions[$k]);
                continue;
            }
            $GLOBALS['log']->lwrite('   ' . $p['pos'] . ' ' . $p['type'] . ' ' . $p['dir']);

        }

        if (empty($positions)) {
            if ($prev_loc_hold) {
                $positions [] = $prev_loc_hold;
            }
            else {
                $GLOBALS['log']->lwrite('Aborting due to empty positions');
                return 'A';
            }
        }

        // find closest position to target
        $least_distance = 0;
        $least_pos = null;
        foreach ($positions as $p) {
            $dis = MathFacade::findMDistanceBetweenTwoPositions($p['pos'], $target);
            if (!$least_pos || $least_distance >= $dis ) {
                if ($least_distance == $dis && $dis != 0) {
                    $best = $this->compare($least_pos['pos'], $p['pos']);
                    if ($best->__toString() != $p['pos']) {
                        continue;
                    }
                }
                $least_pos = $p;
                $least_distance = $dis;
            }
        }
        $dir = $least_pos['dir'];

        $GLOBALS['log']->lwrite("E: " . $dir . "-" . $origin . "-" . $target);
        return $dir;
    }

    public function compare(Position $a, Position $b) {
        $atype = WorldFacade::whatIsAt($this->world->getMap(), $a);
        $btype = WorldFacade::whatIsAt($this->world->getMap(), $b);
        if ($atype == " ") {
            return $a;
        }
        if ($btype == " ") {
            return $b;
        }
        if ($atype == ".") {
            return $a;
        }
        if ($btype == ".") {
            return $b;
        }
        else return $a;
    }

    public function doesDirectionAffectMap($direction) {
        $new_world = Lifter::checkMove($this->world, $direction);
        if ($this->world->getRobotLoc()->__toString() == $new_world->getRobotLoc()->__toString()
            && !$new_world->getEnding()) {
            return false;
        }
        else return true;
    }

    public function doesDirectionLeadToDeath($direction) {
        $new_world = Lifter::checkMove($this->world, $direction);
        if ($new_world->getEnding() && $new_world->getEnding() != "WIN") {
            return true;
        }
        else return false;
    }

    public function move($direction) {

        if ($direction == 'A') {
            Move::abort();
            return true;
        }

        if (!$this->doesDirectionAffectMap($direction)) {
            if ($this->attempt_count > 3) {
                $GLOBALS['log']->lwrite('Aborting due to too many bad attempts');
                Move::abort();
                return true;
            }
            $this->attempt_count ++;
            return false;
        }

        if ($this->doesDirectionLeadToDeath($direction)) {
            $GLOBALS['log']->lwrite('Aborting due to impending death');
            Move::abort();
        }
        else {
            Move::makeMove($direction);
        }
        return true;
    }
}