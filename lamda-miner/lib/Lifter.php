<?php

class Lifter {

    public static function checkMove(World $world, $direction) {
        if (file_exists('./lifter2')) {
            $bin = './lifter2';
        }
        else $bin = "./lamda-miner/lifter2";
        $cmd = $bin . " '" . $world->json . "' " . $direction;
        $shell_return = shell_exec($cmd);
        $new_world = new World($shell_return);
        return $new_world;
    }
}