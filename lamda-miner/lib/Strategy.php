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
            $d = MathFacade::findDistanceBetweenTwoPositions($origin, $l);
            if (!$least_dist || $d < $least_dist) {
                $least_dist = $d;
                $target_lamda = $l;
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
            $GLOBALS['log']->lwrite($dir);
            if ($dir == 'R') $dir = 'D';
            if ($dir == 'L') $dir = 'U';
            if ($dir == 'D') $dir = 'L';
            if ($dir == 'U') $dir = 'R';
        }
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
        $cmd = "./lifter2 '" . $this->world->json . "' " . $direction;
        $shell_return = shell_exec($cmd);
        $world = new World($shell_return);
        //$GLOBALS['log']->lwrite($this->world->getRobotLoc()->__toString() . ':' . $world->getRobotLoc()->__toString() . ':' . $direction);
        if ($this->world->getRobotLoc()->__toString() == $world->getRobotLoc()->__toString()) {
            return false;
        }
        else return true;
    }
}