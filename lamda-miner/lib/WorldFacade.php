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

    public static function whatIsAt(Map $map, $coord) {
        $rows = $map->getRows();
        return $rows[$coord->y][$coord->x];
    }

}