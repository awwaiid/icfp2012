<?php

class Strategy {

    public $world;

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
            $GLOBALS['log']->lwrite($d);
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

    public function findDirectionToTarget(Position $origin, Position $target, $bad_direction = null) {
        $diff_in_height = abs($target->y - $origin->y);
        $diff_in_width = abs($target->x - $origin->x);

        $up = $target->y > $origin->y ? true : false;
        $right = $target->x > $origin->x ? true : false;

        $options = array();
        $options [] = ($up) ? $origin->up() : $origin->down();
        $options [] = ($right) ? $origin->right() : $origin->left();

        if ($diff_in_height > $diff_in_width) {
            $dir = $options[0] == $origin->up() ? 'U' : 'D';
        }
        if ($diff_in_height < $diff_in_width) {
            $dir = $options[1] == $origin->right() ? 'R' : 'L';
        }
        if ($diff_in_height == $diff_in_width) {
            $best = $this->compare($options[0], $options[1]);
            if ($best == $origin->up()) $dir = 'U';
            if ($best == $origin->down()) $dir = 'D';
            if ($best == $origin->right()) $dir = 'R';
            if ($best == $origin->left()) $dir = 'L';
        }

        if ($dir == $bad_direction) {
            if ($dir == 'R') $dir = rand(0,1) ? 'D' : 'U';
            else if ($dir == 'L') $dir = rand(0,1) ? 'U' : 'D';
            else if ($dir == 'D') $dir = rand(0,1) ? 'R' : 'L';
            else if ($dir == 'U') $dir = rand(0,1) ? 'L' : 'R';
        }

        $GLOBALS['log']->lwrite($dir . "-" . $bad_direction . "-" . $origin . "-" . $target);
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
        if ($this->world->getRobotLoc()->__toString() == $new_world->getRobotLoc()->__toString()) {
            return false;
        }
        else return true;
    }

    public function doesDirectionLeadToDeath($direction) {
        $new_world = Lifter::checkMove($this->world, $direction);
        if ($new_world->getEnding()) {
            return true;
        }
        else return false;
    }

    public function move($direction) {
        if ($this->doesDirectionLeadToDeath($direction)) {
            Move::makeMove('A');
        }
        else {
            Move::makeMove($direction);
        }
    }
}