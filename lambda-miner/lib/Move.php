<?php

class Move {
    public static function makeMove($direction) {
        $GLOBALS['log']->lwrite('Made move - ' . $direction);
        echo $direction;
    }

    public static function abort() {
        echo 'A';
    }
}