<?php

class WorldFacade {

    public static function findLambdas(Map $map) {
        $coords = array();
        foreach ($map->getRows() as $y=>$row) {
            if (in_array("\\", $row)) {
                foreach ($row as $x=>$r) {
                    if ($r == "\\") {
                        $coords[] = self::getCoord($x, $y, $map->getDimensions());
                    }
                }
            }
        }
        return $coords;
    }

    public function getCoord($x, $y, $dim) {
        $y = $dim[1] - 1 - $y;
        return new Position($x, $y);
    }

    public static function findMiner(Map $map) {
        foreach ($map->getRows() as $y=>$row) {
            if (in_array("R", $row)) {
                foreach ($row as $x=>$r) {
                    if ($r == "R") {
                        return self::getCoord($x, $y, $map->getDimensions());
                    }
                }
            }
        }
        return false;
    }

    public static function findLift(Map $map) {
        foreach ($map->getRows() as $y=>$row) {
            if (in_array("O", $row) || in_array("L", $row)) {
                foreach ($row as $x=>$r) {
                    if ($r == "O" || $r == "L") {
                        return self::getCoord($x, $y, $map->getDimensions());
                    }
                }
            }
        }
        return false;
    }

    public static function getAdjacentPositions(Map $map, Position $pos) {

        $positions = array();
        $up_pos = new Position($pos->x, $pos->y + 1);
        $down_pos =  new Position($pos->x, $pos->y - 1);
        $left_pos =  new Position($pos->x - 1, $pos->y);
        $right_pos = new Position($pos->x + 1, $pos->y);

        $up = self::whatIsAt($map, $up_pos);
        $down = self::whatIsAt($map,$down_pos);
        $left = self::whatIsAt($map,$left_pos);
        $right = self::whatIsAt($map, $right_pos);

        $types =  array('U'=>$up, 'D'=>$down, 'L'=>$left, 'R'=>$right);
        $GLOBALS['log']->lwrite(json_encode($types));
        $positions = array('U'=>$up_pos, 'D'=>$down_pos, 'L'=>$left_pos, 'R'=>$right_pos);

        $out = array();
        foreach ($types as $k=>$p) {
            if (!$p || $p == '#' || $p =='L' || $p == 'W' || is_int($p)) {
                unset ($positions[$k]);
            }
            else {
                $out [] = array('pos'=>$positions[$k], 'dir'=>$k, 'type'=>$p);
            }
        }
        return $out;

    }

    public static function whatIsAt(Map $map, $coord) {
        $rows = $map->getRows();
        //$GLOBALS['log']->lwrite(print_r($rows, true));
        return $rows[count($rows) - 1 - $coord->y][$coord->x];
    }

}