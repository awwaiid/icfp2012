#!/usr/bin/php
<?php

$f = fopen('php://stdin', 'r');

$move_queue = array();
while ($line = fgets($f)) {
    //fwrite (STDERR, $line . "\n");

    if (!empty($move_queue)) {
        //fwrite(STDERR, implode(',', $move_queue) . "\n");
        $dir = array_shift($move_queue);
        //fwrite(STDERR, $dir . "\n");
        fwrite(STDOUT, $dir . "\n");
        continue;
    }

    $start_world = json_decode($line);
    $start_score = $start_world->score;

    // fwrite(STDERR, "Looking ahead 22 moves\n");
    for ($i = 0; $i < 22; $i++) {
        $dir = shell_exec("lamda-miner/phpbot.php '" . $line . "'");
        $line = Lifter::checkMove($line, $dir);
        $move_queue [] = $dir;
        $world = json_decode ($line);
        if (isset($world->ending)) break;

    }

    // foreach ($move_queue as $k=>$m) {
        // fwrite (STDERR, $m);
    // }
    // fwrite (STDERR, "\n");

    $ending_score = $world->score;
    // fwrite(STDERR, $start_score . ' - ' . $ending_score . "\n");
    if ($start_score >= $ending_score) {
        // fwrite(STDERR, "Aborting because score gets worse\n");
        $dir = 'A';
    }
    else {
        // make first move.
        //fwrite(STDERR, implode(',', $move_queue) . "\n");
        $dir = array_shift($move_queue);
    }
    //fwrite(STDERR, $dir . "\n");
    fwrite(STDOUT, $dir . "\n");
}

class Lifter {

    public static function checkMove($world_json, $direction) {
        $bin = "./lamda-miner/lifter2";
        $cmd = $bin . " '" . $world_json . "' " . $direction;
        $shell_return = shell_exec($cmd);
        return $shell_return;
    }
}
