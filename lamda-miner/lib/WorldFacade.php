<?php

class WorldFacade {

    public static function findLambdas(Map $map) {
        $coords = array();
        foreach ($map->getRows() as $h=>$row) {
            if (in_array("\\", $row)) {
                //var_dump ($row);
                foreach ($row as $w=>$r) {
                    if ($r == "\\") {
                        $coords[] = self::getCoord($h, $w, $map->getDimensions());
                    }
                }
            }
        }
        return $coords;
    }

    public function getCoord($h, $w, $dim) {
        $h = $dim[1] - 1 - $h;
        $w = $w;
        return array('w'=>$w, 'h'=>$h);
    }

    public static function findMiner(Map $map) {
        foreach ($map->getRows() as $h=>$row) {
            if (in_array("R", $row)) {
                foreach ($row as $w=>$r) {
                    if ($r == "R") {
                        return self::getCoord($h, $w, $map->getDimensions());
                    }
                }
            }
        }
        return false;
    }

    public static function whatIsAt(Map $map, $coord) {
        $rows = $map->getRows();
        return $rows[$coord['h']][$coord['w']];
    }

}